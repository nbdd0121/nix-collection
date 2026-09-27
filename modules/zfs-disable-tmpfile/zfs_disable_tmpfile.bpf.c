#include <linux/bpf.h>
#include <linux/errno.h>
#include <stdbool.h>

#include <bpf/bpf_core_read.h>
#include <bpf/bpf_tracing.h>

#define ZFS_SUPER_MAGIC 0x2fc12fc1UL

struct super_block {
  unsigned long s_magic;
} __attribute__((preserve_access_index));

struct inode {
  struct super_block *i_sb;
} __attribute__((preserve_access_index));

struct {
  __uint(type, BPF_MAP_TYPE_TASK_STORAGE);
  __uint(map_flags, BPF_F_NO_PREALLOC);
  __type(key, int);
  __type(value, bool);
} in_vfs_tmpfile SEC(".maps");

// There is no place for LSM hooks to intercept vfs_tmpfile before it invokes ->tmpfile.
// It does permission-checks the parent directory before hand, so we use kprobe to determine
// if we're in a vfs_tmpfile call, and then intercept the permission check instead.
SEC("kprobe/vfs_tmpfile")
int mark_tmpfile(struct pt_regs *_ctx) {
  bool *flag = bpf_task_storage_get(&in_vfs_tmpfile, bpf_get_current_task_btf(), NULL,
                              BPF_LOCAL_STORAGE_GET_F_CREATE);
  if (flag)
    *flag = true;
  return 0;
}

SEC("kretprobe/vfs_tmpfile")
int clear_tmpfile(struct pt_regs *_ctx) {
  bpf_task_storage_delete(&in_vfs_tmpfile, bpf_get_current_task_btf());
  return 0;
}

SEC("lsm/inode_permission")
int BPF_PROG(block_in_vfs_tmpfile, struct inode *inode, int mask) {
  // Outside vfs_tmpfile access path, do not intercept.
  bool *flag = bpf_task_storage_get(&in_vfs_tmpfile, bpf_get_current_task_btf(), NULL, 0);
  if (!flag || !*flag) {
	return 0;
  }

  if (BPF_CORE_READ(inode, i_sb, s_magic) != ZFS_SUPER_MAGIC)
    return 0;

  return -EOPNOTSUPP;
}

char LICENSE[] SEC("license") = "GPL";

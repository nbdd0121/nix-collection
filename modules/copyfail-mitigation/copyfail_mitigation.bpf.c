#include <linux/errno.h>
#include <linux/if_alg.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

#define AF_ALG 38

SEC("lsm/socket_bind")
int BPF_PROG(copyfail_mitigation, struct socket *sock,
             struct sockaddr_alg *address, int addrlen) {
  unsigned short family;
  if (bpf_probe_read_kernel(&family, sizeof(family), &address->salg_family) != 0 ||
      family != AF_ALG)
    return 0;

  char name[__builtin_strlen("authencesn")];
  struct sockaddr_alg *alg_addr = (struct sockaddr_alg *)address;

  if (bpf_probe_read_kernel(name, sizeof(name), alg_addr->salg_name) != 0 ||
      __builtin_memcmp(name, "authencesn", 10) != 0)
    return 0;

  bpf_printk("Blocking bind to AF_ALG authencesn\n");
  return -ENOENT;
}

char LICENSE[] SEC("license") = "GPL";

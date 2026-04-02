{ lib }: with lib.kernel; {
  IOSCHED_BFQ = yes;
  DEFAULT_BFQ = yes;
  DEFAULT_IOSCHED = "bfq";
  V4L2_LOOPBACK = module;
}

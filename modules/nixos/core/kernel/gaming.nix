{ lib }: with lib.kernel; {
  HZ_1000 = yes;
  HZ = 1000;
  PREEMPT_FULL = yes;
  IOSCHED_BFQ = yes;
  DEFAULT_BFQ = yes;
  DEFAULT_IOSCHED = "bfq";
  HID = yes;
}

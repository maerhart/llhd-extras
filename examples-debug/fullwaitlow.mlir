llhd.entity @root () -> () {
  %0 = llhd.const 0 : i32
  %1 = llhd.sig "s1" %0 : i32
  %2 = llhd.sig "s2" %0 : i32
  llhd.inst "proc" @proc () -> (%1, %2) : () -> (!llhd.sig<i32>, !llhd.sig<i32>)
}

llhd.proc @proc () -> (%a : !llhd.sig<i32>, %b : !llhd.sig<i32>) {
  br ^timed
^timed:
  %t1 = llhd.const #llhd.time<0ns, 0d, 1e> : !llhd.time
  %t2 = llhd.const #llhd.time<0ns, 0d, 2e>: !llhd.time
  llhd.wait for %t1, ^observe
^observe:
    // run at 0ns 1e
  %c0 = llhd.const 1 : i32
  %p0 = llhd.prb %b : !llhd.sig<i32>
  %a0 = addi %c0, %p0 : i32
  llhd.drv %a, %a0 after %t1 : !llhd.sig<i32>   // drive 1 at 0ns 2e
  llhd.drv %b, %a0 after %t2 : !llhd.sig<i32>   // drive 1 at 0ns 3e
  llhd.wait (%b : !llhd.sig<i32>), ^timed_observe
^timed_observe:
    // run at 0ns 3e
  %p1 = llhd.prb %b : !llhd.sig<i32>
  %a1 = addi %c0, %p1 : i32
  llhd.drv %b, %a1 after %t1 : !llhd.sig<i32>   // drive 2 at 0ns 4e
  llhd.wait for %t2, (%b : !llhd.sig<i32>), ^overlap_invalidated // time trigger at 0ns 5e
^overlap_invalidated:
    // run at 0ns 4e
  %p2 = llhd.prb %b : !llhd.sig<i32>
  %a2 = addi %c0, %p2 : i32
  llhd.drv %b, %a2 after %t1 : !llhd.sig<i32>   // drive 3 at 0ns 5e
  llhd.wait for %t2, ^observe_both
^observe_both:
    // run at 0ns 6e
  %p3 = llhd.prb %b : !llhd.sig<i32>
  %a3 = addi %c0, %p3 : i32
  llhd.drv %a, %a3 after %t2 : !llhd.sig<i32>   // drive 3 at 0ns 8e
  llhd.drv %b, %a3 after %t2 : !llhd.sig<i32>   // drive 3 at 0ns 8e
  llhd.wait (%a, %b : !llhd.sig<i32>, !llhd.sig<i32>), ^blockArgs
^blockArgs:
  %p4 = llhd.prb %b : !llhd.sig<i32>
  %a4 = addi %c0, %p4 : i32
  llhd.wait (%a, %b : !llhd.sig<i32>, !llhd.sig<i32>), ^end(%a4 : i32)
^end (%arg : i32):
    // run at 0ns 6e
  llhd.drv %b, %arg after %t2 : !llhd.sig<i32>   // drive 4 at 0ns 10e
  llhd.halt
}


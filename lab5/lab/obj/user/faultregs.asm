
obj/user/faultregs.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 37 05 00 00       	call   800568 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	89 c3                	mov    %eax,%ebx
  80003f:	89 ce                	mov    %ecx,%esi
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800041:	8b 45 08             	mov    0x8(%ebp),%eax
  800044:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800048:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004c:	c7 44 24 04 11 25 80 	movl   $0x802511,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 e0 24 80 00 	movl   $0x8024e0,(%esp)
  80005b:	e8 70 06 00 00       	call   8006d0 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 06                	mov    (%esi),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 03                	mov    (%ebx),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 f0 24 80 	movl   $0x8024f0,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 f4 24 80 00 	movl   $0x8024f4,(%esp)
  80007b:	e8 50 06 00 00       	call   8006d0 <cprintf>
  800080:	8b 06                	mov    (%esi),%eax
  800082:	39 03                	cmp    %eax,(%ebx)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 04 25 80 00 	movl   $0x802504,(%esp)
  80008d:	e8 3e 06 00 00       	call   8006d0 <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800092:	bf 00 00 00 00       	mov    $0x0,%edi
  800097:	eb 11                	jmp    8000aa <check_regs+0x76>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800099:	c7 04 24 08 25 80 00 	movl   $0x802508,(%esp)
  8000a0:	e8 2b 06 00 00       	call   8006d0 <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 46 04             	mov    0x4(%esi),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 12 25 80 	movl   $0x802512,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 f4 24 80 00 	movl   $0x8024f4,(%esp)
  8000c7:	e8 04 06 00 00       	call   8006d0 <cprintf>
  8000cc:	8b 46 04             	mov    0x4(%esi),%eax
  8000cf:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 04 25 80 00 	movl   $0x802504,(%esp)
  8000db:	e8 f0 05 00 00       	call   8006d0 <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 08 25 80 00 	movl   $0x802508,(%esp)
  8000e9:	e8 e2 05 00 00       	call   8006d0 <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 46 08             	mov    0x8(%esi),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 16 25 80 	movl   $0x802516,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 f4 24 80 00 	movl   $0x8024f4,(%esp)
  800110:	e8 bb 05 00 00       	call   8006d0 <cprintf>
  800115:	8b 46 08             	mov    0x8(%esi),%eax
  800118:	39 43 08             	cmp    %eax,0x8(%ebx)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 04 25 80 00 	movl   $0x802504,(%esp)
  800124:	e8 a7 05 00 00       	call   8006d0 <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 08 25 80 00 	movl   $0x802508,(%esp)
  800132:	e8 99 05 00 00       	call   8006d0 <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 46 10             	mov    0x10(%esi),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 43 10             	mov    0x10(%ebx),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 1a 25 80 	movl   $0x80251a,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 f4 24 80 00 	movl   $0x8024f4,(%esp)
  800159:	e8 72 05 00 00       	call   8006d0 <cprintf>
  80015e:	8b 46 10             	mov    0x10(%esi),%eax
  800161:	39 43 10             	cmp    %eax,0x10(%ebx)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 04 25 80 00 	movl   $0x802504,(%esp)
  80016d:	e8 5e 05 00 00       	call   8006d0 <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 08 25 80 00 	movl   $0x802508,(%esp)
  80017b:	e8 50 05 00 00       	call   8006d0 <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 46 14             	mov    0x14(%esi),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 43 14             	mov    0x14(%ebx),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 1e 25 80 	movl   $0x80251e,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 f4 24 80 00 	movl   $0x8024f4,(%esp)
  8001a2:	e8 29 05 00 00       	call   8006d0 <cprintf>
  8001a7:	8b 46 14             	mov    0x14(%esi),%eax
  8001aa:	39 43 14             	cmp    %eax,0x14(%ebx)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 04 25 80 00 	movl   $0x802504,(%esp)
  8001b6:	e8 15 05 00 00       	call   8006d0 <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 08 25 80 00 	movl   $0x802508,(%esp)
  8001c4:	e8 07 05 00 00       	call   8006d0 <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 46 18             	mov    0x18(%esi),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 22 25 80 	movl   $0x802522,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 f4 24 80 00 	movl   $0x8024f4,(%esp)
  8001eb:	e8 e0 04 00 00       	call   8006d0 <cprintf>
  8001f0:	8b 46 18             	mov    0x18(%esi),%eax
  8001f3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 04 25 80 00 	movl   $0x802504,(%esp)
  8001ff:	e8 cc 04 00 00       	call   8006d0 <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 08 25 80 00 	movl   $0x802508,(%esp)
  80020d:	e8 be 04 00 00       	call   8006d0 <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 26 25 80 	movl   $0x802526,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 f4 24 80 00 	movl   $0x8024f4,(%esp)
  800234:	e8 97 04 00 00       	call   8006d0 <cprintf>
  800239:	8b 46 1c             	mov    0x1c(%esi),%eax
  80023c:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 04 25 80 00 	movl   $0x802504,(%esp)
  800248:	e8 83 04 00 00       	call   8006d0 <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 08 25 80 00 	movl   $0x802508,(%esp)
  800256:	e8 75 04 00 00       	call   8006d0 <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 46 20             	mov    0x20(%esi),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 43 20             	mov    0x20(%ebx),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 2a 25 80 	movl   $0x80252a,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 f4 24 80 00 	movl   $0x8024f4,(%esp)
  80027d:	e8 4e 04 00 00       	call   8006d0 <cprintf>
  800282:	8b 46 20             	mov    0x20(%esi),%eax
  800285:	39 43 20             	cmp    %eax,0x20(%ebx)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 04 25 80 00 	movl   $0x802504,(%esp)
  800291:	e8 3a 04 00 00       	call   8006d0 <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 08 25 80 00 	movl   $0x802508,(%esp)
  80029f:	e8 2c 04 00 00       	call   8006d0 <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 46 24             	mov    0x24(%esi),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 43 24             	mov    0x24(%ebx),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 2e 25 80 	movl   $0x80252e,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 f4 24 80 00 	movl   $0x8024f4,(%esp)
  8002c6:	e8 05 04 00 00       	call   8006d0 <cprintf>
  8002cb:	8b 46 24             	mov    0x24(%esi),%eax
  8002ce:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 04 25 80 00 	movl   $0x802504,(%esp)
  8002da:	e8 f1 03 00 00       	call   8006d0 <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 08 25 80 00 	movl   $0x802508,(%esp)
  8002e8:	e8 e3 03 00 00       	call   8006d0 <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 46 28             	mov    0x28(%esi),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 43 28             	mov    0x28(%ebx),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 35 25 80 	movl   $0x802535,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 f4 24 80 00 	movl   $0x8024f4,(%esp)
  80030f:	e8 bc 03 00 00       	call   8006d0 <cprintf>
  800314:	8b 46 28             	mov    0x28(%esi),%eax
  800317:	39 43 28             	cmp    %eax,0x28(%ebx)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 04 25 80 00 	movl   $0x802504,(%esp)
  800323:	e8 a8 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 39 25 80 00 	movl   $0x802539,(%esp)
  800336:	e8 95 03 00 00       	call   8006d0 <cprintf>
	if (!mismatch)
  80033b:	85 ff                	test   %edi,%edi
  80033d:	74 23                	je     800362 <check_regs+0x32e>
  80033f:	eb 2f                	jmp    800370 <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800341:	c7 04 24 08 25 80 00 	movl   $0x802508,(%esp)
  800348:	e8 83 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 39 25 80 00 	movl   $0x802539,(%esp)
  80035b:	e8 70 03 00 00       	call   8006d0 <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 04 25 80 00 	movl   $0x802504,(%esp)
  800369:	e8 62 03 00 00       	call   8006d0 <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 08 25 80 00 	movl   $0x802508,(%esp)
  800377:	e8 54 03 00 00       	call   8006d0 <cprintf>
}
  80037c:	83 c4 1c             	add    $0x1c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	83 ec 20             	sub    $0x20,%esp
  80038c:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038f:	8b 10                	mov    (%eax),%edx
  800391:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800397:	74 27                	je     8003c0 <pgfault+0x3c>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800399:	8b 40 28             	mov    0x28(%eax),%eax
  80039c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a4:	c7 44 24 08 a0 25 80 	movl   $0x8025a0,0x8(%esp)
  8003ab:	00 
  8003ac:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b3:	00 
  8003b4:	c7 04 24 47 25 80 00 	movl   $0x802547,(%esp)
  8003bb:	e8 18 02 00 00       	call   8005d8 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003c0:	bf 80 40 80 00       	mov    $0x804080,%edi
  8003c5:	8d 70 08             	lea    0x8(%eax),%esi
  8003c8:	b9 08 00 00 00       	mov    $0x8,%ecx
  8003cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	during.eip = utf->utf_eip;
  8003cf:	8b 50 28             	mov    0x28(%eax),%edx
  8003d2:	89 17                	mov    %edx,(%edi)
	during.eflags = utf->utf_eflags & ~FL_RF;
  8003d4:	8b 50 2c             	mov    0x2c(%eax),%edx
  8003d7:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  8003dd:	89 15 a4 40 80 00    	mov    %edx,0x8040a4
	during.esp = utf->utf_esp;
  8003e3:	8b 40 30             	mov    0x30(%eax),%eax
  8003e6:	a3 a8 40 80 00       	mov    %eax,0x8040a8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  8003eb:	c7 44 24 04 5f 25 80 	movl   $0x80255f,0x4(%esp)
  8003f2:	00 
  8003f3:	c7 04 24 6d 25 80 00 	movl   $0x80256d,(%esp)
  8003fa:	b9 80 40 80 00       	mov    $0x804080,%ecx
  8003ff:	ba 58 25 80 00       	mov    $0x802558,%edx
  800404:	b8 00 40 80 00       	mov    $0x804000,%eax
  800409:	e8 26 fc ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80040e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800415:	00 
  800416:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80041d:	00 
  80041e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800425:	e8 63 0c 00 00       	call   80108d <sys_page_alloc>
  80042a:	85 c0                	test   %eax,%eax
  80042c:	79 20                	jns    80044e <pgfault+0xca>
		panic("sys_page_alloc: %e", r);
  80042e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800432:	c7 44 24 08 74 25 80 	movl   $0x802574,0x8(%esp)
  800439:	00 
  80043a:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800441:	00 
  800442:	c7 04 24 47 25 80 00 	movl   $0x802547,(%esp)
  800449:	e8 8a 01 00 00       	call   8005d8 <_panic>
}
  80044e:	83 c4 20             	add    $0x20,%esp
  800451:	5e                   	pop    %esi
  800452:	5f                   	pop    %edi
  800453:	5d                   	pop    %ebp
  800454:	c3                   	ret    

00800455 <umain>:

void
umain(int argc, char **argv)
{
  800455:	55                   	push   %ebp
  800456:	89 e5                	mov    %esp,%ebp
  800458:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  80045b:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  800462:	e8 91 0e 00 00       	call   8012f8 <set_pgfault_handler>

	asm volatile(
  800467:	50                   	push   %eax
  800468:	9c                   	pushf  
  800469:	58                   	pop    %eax
  80046a:	0d d5 08 00 00       	or     $0x8d5,%eax
  80046f:	50                   	push   %eax
  800470:	9d                   	popf   
  800471:	a3 24 40 80 00       	mov    %eax,0x804024
  800476:	8d 05 b1 04 80 00    	lea    0x8004b1,%eax
  80047c:	a3 20 40 80 00       	mov    %eax,0x804020
  800481:	58                   	pop    %eax
  800482:	89 3d 00 40 80 00    	mov    %edi,0x804000
  800488:	89 35 04 40 80 00    	mov    %esi,0x804004
  80048e:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  800494:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  80049a:	89 15 14 40 80 00    	mov    %edx,0x804014
  8004a0:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  8004a6:	a3 1c 40 80 00       	mov    %eax,0x80401c
  8004ab:	89 25 28 40 80 00    	mov    %esp,0x804028
  8004b1:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004b8:	00 00 00 
  8004bb:	89 3d 40 40 80 00    	mov    %edi,0x804040
  8004c1:	89 35 44 40 80 00    	mov    %esi,0x804044
  8004c7:	89 2d 48 40 80 00    	mov    %ebp,0x804048
  8004cd:	89 1d 50 40 80 00    	mov    %ebx,0x804050
  8004d3:	89 15 54 40 80 00    	mov    %edx,0x804054
  8004d9:	89 0d 58 40 80 00    	mov    %ecx,0x804058
  8004df:	a3 5c 40 80 00       	mov    %eax,0x80405c
  8004e4:	89 25 68 40 80 00    	mov    %esp,0x804068
  8004ea:	8b 3d 00 40 80 00    	mov    0x804000,%edi
  8004f0:	8b 35 04 40 80 00    	mov    0x804004,%esi
  8004f6:	8b 2d 08 40 80 00    	mov    0x804008,%ebp
  8004fc:	8b 1d 10 40 80 00    	mov    0x804010,%ebx
  800502:	8b 15 14 40 80 00    	mov    0x804014,%edx
  800508:	8b 0d 18 40 80 00    	mov    0x804018,%ecx
  80050e:	a1 1c 40 80 00       	mov    0x80401c,%eax
  800513:	8b 25 28 40 80 00    	mov    0x804028,%esp
  800519:	50                   	push   %eax
  80051a:	9c                   	pushf  
  80051b:	58                   	pop    %eax
  80051c:	a3 64 40 80 00       	mov    %eax,0x804064
  800521:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800522:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800529:	74 0c                	je     800537 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80052b:	c7 04 24 d4 25 80 00 	movl   $0x8025d4,(%esp)
  800532:	e8 99 01 00 00       	call   8006d0 <cprintf>
	after.eip = before.eip;
  800537:	a1 20 40 80 00       	mov    0x804020,%eax
  80053c:	a3 60 40 80 00       	mov    %eax,0x804060

	check_regs(&before, "before", &after, "after", "after page-fault");
  800541:	c7 44 24 04 87 25 80 	movl   $0x802587,0x4(%esp)
  800548:	00 
  800549:	c7 04 24 98 25 80 00 	movl   $0x802598,(%esp)
  800550:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800555:	ba 58 25 80 00       	mov    $0x802558,%edx
  80055a:	b8 00 40 80 00       	mov    $0x804000,%eax
  80055f:	e8 d0 fa ff ff       	call   800034 <check_regs>
}
  800564:	c9                   	leave  
  800565:	c3                   	ret    
	...

00800568 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800568:	55                   	push   %ebp
  800569:	89 e5                	mov    %esp,%ebp
  80056b:	56                   	push   %esi
  80056c:	53                   	push   %ebx
  80056d:	83 ec 10             	sub    $0x10,%esp
  800570:	8b 75 08             	mov    0x8(%ebp),%esi
  800573:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800576:	e8 d4 0a 00 00       	call   80104f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80057b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800580:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800587:	c1 e0 07             	shl    $0x7,%eax
  80058a:	29 d0                	sub    %edx,%eax
  80058c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800591:	a3 b0 40 80 00       	mov    %eax,0x8040b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800596:	85 f6                	test   %esi,%esi
  800598:	7e 07                	jle    8005a1 <libmain+0x39>
		binaryname = argv[0];
  80059a:	8b 03                	mov    (%ebx),%eax
  80059c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a5:	89 34 24             	mov    %esi,(%esp)
  8005a8:	e8 a8 fe ff ff       	call   800455 <umain>

	// exit gracefully
	exit();
  8005ad:	e8 0a 00 00 00       	call   8005bc <exit>
}
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	5b                   	pop    %ebx
  8005b6:	5e                   	pop    %esi
  8005b7:	5d                   	pop    %ebp
  8005b8:	c3                   	ret    
  8005b9:	00 00                	add    %al,(%eax)
	...

008005bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005bc:	55                   	push   %ebp
  8005bd:	89 e5                	mov    %esp,%ebp
  8005bf:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8005c2:	e8 dc 0f 00 00       	call   8015a3 <close_all>
	sys_env_destroy(0);
  8005c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005ce:	e8 2a 0a 00 00       	call   800ffd <sys_env_destroy>
}
  8005d3:	c9                   	leave  
  8005d4:	c3                   	ret    
  8005d5:	00 00                	add    %al,(%eax)
	...

008005d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005d8:	55                   	push   %ebp
  8005d9:	89 e5                	mov    %esp,%ebp
  8005db:	56                   	push   %esi
  8005dc:	53                   	push   %ebx
  8005dd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005e0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005e3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8005e9:	e8 61 0a 00 00       	call   80104f <sys_getenvid>
  8005ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800600:	89 44 24 04          	mov    %eax,0x4(%esp)
  800604:	c7 04 24 00 26 80 00 	movl   $0x802600,(%esp)
  80060b:	e8 c0 00 00 00       	call   8006d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800610:	89 74 24 04          	mov    %esi,0x4(%esp)
  800614:	8b 45 10             	mov    0x10(%ebp),%eax
  800617:	89 04 24             	mov    %eax,(%esp)
  80061a:	e8 50 00 00 00       	call   80066f <vcprintf>
	cprintf("\n");
  80061f:	c7 04 24 10 25 80 00 	movl   $0x802510,(%esp)
  800626:	e8 a5 00 00 00       	call   8006d0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80062b:	cc                   	int3   
  80062c:	eb fd                	jmp    80062b <_panic+0x53>
	...

00800630 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	53                   	push   %ebx
  800634:	83 ec 14             	sub    $0x14,%esp
  800637:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80063a:	8b 03                	mov    (%ebx),%eax
  80063c:	8b 55 08             	mov    0x8(%ebp),%edx
  80063f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800643:	40                   	inc    %eax
  800644:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800646:	3d ff 00 00 00       	cmp    $0xff,%eax
  80064b:	75 19                	jne    800666 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80064d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800654:	00 
  800655:	8d 43 08             	lea    0x8(%ebx),%eax
  800658:	89 04 24             	mov    %eax,(%esp)
  80065b:	e8 60 09 00 00       	call   800fc0 <sys_cputs>
		b->idx = 0;
  800660:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800666:	ff 43 04             	incl   0x4(%ebx)
}
  800669:	83 c4 14             	add    $0x14,%esp
  80066c:	5b                   	pop    %ebx
  80066d:	5d                   	pop    %ebp
  80066e:	c3                   	ret    

0080066f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
  800672:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800678:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80067f:	00 00 00 
	b.cnt = 0;
  800682:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800689:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80068c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800693:	8b 45 08             	mov    0x8(%ebp),%eax
  800696:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a4:	c7 04 24 30 06 80 00 	movl   $0x800630,(%esp)
  8006ab:	e8 82 01 00 00       	call   800832 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006b0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ba:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c0:	89 04 24             	mov    %eax,(%esp)
  8006c3:	e8 f8 08 00 00       	call   800fc0 <sys_cputs>

	return b.cnt;
}
  8006c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e0:	89 04 24             	mov    %eax,(%esp)
  8006e3:	e8 87 ff ff ff       	call   80066f <vcprintf>
	va_end(ap);

	return cnt;
}
  8006e8:	c9                   	leave  
  8006e9:	c3                   	ret    
	...

008006ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	57                   	push   %edi
  8006f0:	56                   	push   %esi
  8006f1:	53                   	push   %ebx
  8006f2:	83 ec 3c             	sub    $0x3c,%esp
  8006f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f8:	89 d7                	mov    %edx,%edi
  8006fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800700:	8b 45 0c             	mov    0xc(%ebp),%eax
  800703:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800706:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800709:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80070c:	85 c0                	test   %eax,%eax
  80070e:	75 08                	jne    800718 <printnum+0x2c>
  800710:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800713:	39 45 10             	cmp    %eax,0x10(%ebp)
  800716:	77 57                	ja     80076f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800718:	89 74 24 10          	mov    %esi,0x10(%esp)
  80071c:	4b                   	dec    %ebx
  80071d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800721:	8b 45 10             	mov    0x10(%ebp),%eax
  800724:	89 44 24 08          	mov    %eax,0x8(%esp)
  800728:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80072c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800730:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800737:	00 
  800738:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80073b:	89 04 24             	mov    %eax,(%esp)
  80073e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800741:	89 44 24 04          	mov    %eax,0x4(%esp)
  800745:	e8 46 1b 00 00       	call   802290 <__udivdi3>
  80074a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80074e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800752:	89 04 24             	mov    %eax,(%esp)
  800755:	89 54 24 04          	mov    %edx,0x4(%esp)
  800759:	89 fa                	mov    %edi,%edx
  80075b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80075e:	e8 89 ff ff ff       	call   8006ec <printnum>
  800763:	eb 0f                	jmp    800774 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800765:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800769:	89 34 24             	mov    %esi,(%esp)
  80076c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80076f:	4b                   	dec    %ebx
  800770:	85 db                	test   %ebx,%ebx
  800772:	7f f1                	jg     800765 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800774:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800778:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80077c:	8b 45 10             	mov    0x10(%ebp),%eax
  80077f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800783:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80078a:	00 
  80078b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80078e:	89 04 24             	mov    %eax,(%esp)
  800791:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800794:	89 44 24 04          	mov    %eax,0x4(%esp)
  800798:	e8 13 1c 00 00       	call   8023b0 <__umoddi3>
  80079d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a1:	0f be 80 23 26 80 00 	movsbl 0x802623(%eax),%eax
  8007a8:	89 04 24             	mov    %eax,(%esp)
  8007ab:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8007ae:	83 c4 3c             	add    $0x3c,%esp
  8007b1:	5b                   	pop    %ebx
  8007b2:	5e                   	pop    %esi
  8007b3:	5f                   	pop    %edi
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007b9:	83 fa 01             	cmp    $0x1,%edx
  8007bc:	7e 0e                	jle    8007cc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007be:	8b 10                	mov    (%eax),%edx
  8007c0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007c3:	89 08                	mov    %ecx,(%eax)
  8007c5:	8b 02                	mov    (%edx),%eax
  8007c7:	8b 52 04             	mov    0x4(%edx),%edx
  8007ca:	eb 22                	jmp    8007ee <getuint+0x38>
	else if (lflag)
  8007cc:	85 d2                	test   %edx,%edx
  8007ce:	74 10                	je     8007e0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007d0:	8b 10                	mov    (%eax),%edx
  8007d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007d5:	89 08                	mov    %ecx,(%eax)
  8007d7:	8b 02                	mov    (%edx),%eax
  8007d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007de:	eb 0e                	jmp    8007ee <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007e0:	8b 10                	mov    (%eax),%edx
  8007e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007e5:	89 08                	mov    %ecx,(%eax)
  8007e7:	8b 02                	mov    (%edx),%eax
  8007e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007f6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8007f9:	8b 10                	mov    (%eax),%edx
  8007fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8007fe:	73 08                	jae    800808 <sprintputch+0x18>
		*b->buf++ = ch;
  800800:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800803:	88 0a                	mov    %cl,(%edx)
  800805:	42                   	inc    %edx
  800806:	89 10                	mov    %edx,(%eax)
}
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800810:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800813:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800817:	8b 45 10             	mov    0x10(%ebp),%eax
  80081a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800821:	89 44 24 04          	mov    %eax,0x4(%esp)
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	89 04 24             	mov    %eax,(%esp)
  80082b:	e8 02 00 00 00       	call   800832 <vprintfmt>
	va_end(ap);
}
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	57                   	push   %edi
  800836:	56                   	push   %esi
  800837:	53                   	push   %ebx
  800838:	83 ec 4c             	sub    $0x4c,%esp
  80083b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80083e:	8b 75 10             	mov    0x10(%ebp),%esi
  800841:	eb 12                	jmp    800855 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800843:	85 c0                	test   %eax,%eax
  800845:	0f 84 8b 03 00 00    	je     800bd6 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80084b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084f:	89 04 24             	mov    %eax,(%esp)
  800852:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800855:	0f b6 06             	movzbl (%esi),%eax
  800858:	46                   	inc    %esi
  800859:	83 f8 25             	cmp    $0x25,%eax
  80085c:	75 e5                	jne    800843 <vprintfmt+0x11>
  80085e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800862:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800869:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80086e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800875:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087a:	eb 26                	jmp    8008a2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80087f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800883:	eb 1d                	jmp    8008a2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800885:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800888:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80088c:	eb 14                	jmp    8008a2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800891:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800898:	eb 08                	jmp    8008a2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80089a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80089d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a2:	0f b6 06             	movzbl (%esi),%eax
  8008a5:	8d 56 01             	lea    0x1(%esi),%edx
  8008a8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8008ab:	8a 16                	mov    (%esi),%dl
  8008ad:	83 ea 23             	sub    $0x23,%edx
  8008b0:	80 fa 55             	cmp    $0x55,%dl
  8008b3:	0f 87 01 03 00 00    	ja     800bba <vprintfmt+0x388>
  8008b9:	0f b6 d2             	movzbl %dl,%edx
  8008bc:	ff 24 95 60 27 80 00 	jmp    *0x802760(,%edx,4)
  8008c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008c6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008cb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8008ce:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8008d2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008d5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8008d8:	83 fa 09             	cmp    $0x9,%edx
  8008db:	77 2a                	ja     800907 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008dd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008de:	eb eb                	jmp    8008cb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e3:	8d 50 04             	lea    0x4(%eax),%edx
  8008e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008ee:	eb 17                	jmp    800907 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8008f0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008f4:	78 98                	js     80088e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008f9:	eb a7                	jmp    8008a2 <vprintfmt+0x70>
  8008fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008fe:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800905:	eb 9b                	jmp    8008a2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800907:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80090b:	79 95                	jns    8008a2 <vprintfmt+0x70>
  80090d:	eb 8b                	jmp    80089a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80090f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800910:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800913:	eb 8d                	jmp    8008a2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800915:	8b 45 14             	mov    0x14(%ebp),%eax
  800918:	8d 50 04             	lea    0x4(%eax),%edx
  80091b:	89 55 14             	mov    %edx,0x14(%ebp)
  80091e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800922:	8b 00                	mov    (%eax),%eax
  800924:	89 04 24             	mov    %eax,(%esp)
  800927:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80092d:	e9 23 ff ff ff       	jmp    800855 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800932:	8b 45 14             	mov    0x14(%ebp),%eax
  800935:	8d 50 04             	lea    0x4(%eax),%edx
  800938:	89 55 14             	mov    %edx,0x14(%ebp)
  80093b:	8b 00                	mov    (%eax),%eax
  80093d:	85 c0                	test   %eax,%eax
  80093f:	79 02                	jns    800943 <vprintfmt+0x111>
  800941:	f7 d8                	neg    %eax
  800943:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800945:	83 f8 0f             	cmp    $0xf,%eax
  800948:	7f 0b                	jg     800955 <vprintfmt+0x123>
  80094a:	8b 04 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%eax
  800951:	85 c0                	test   %eax,%eax
  800953:	75 23                	jne    800978 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800955:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800959:	c7 44 24 08 3b 26 80 	movl   $0x80263b,0x8(%esp)
  800960:	00 
  800961:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	89 04 24             	mov    %eax,(%esp)
  80096b:	e8 9a fe ff ff       	call   80080a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800970:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800973:	e9 dd fe ff ff       	jmp    800855 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800978:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80097c:	c7 44 24 08 8a 2a 80 	movl   $0x802a8a,0x8(%esp)
  800983:	00 
  800984:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800988:	8b 55 08             	mov    0x8(%ebp),%edx
  80098b:	89 14 24             	mov    %edx,(%esp)
  80098e:	e8 77 fe ff ff       	call   80080a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800993:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800996:	e9 ba fe ff ff       	jmp    800855 <vprintfmt+0x23>
  80099b:	89 f9                	mov    %edi,%ecx
  80099d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a6:	8d 50 04             	lea    0x4(%eax),%edx
  8009a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ac:	8b 30                	mov    (%eax),%esi
  8009ae:	85 f6                	test   %esi,%esi
  8009b0:	75 05                	jne    8009b7 <vprintfmt+0x185>
				p = "(null)";
  8009b2:	be 34 26 80 00       	mov    $0x802634,%esi
			if (width > 0 && padc != '-')
  8009b7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009bb:	0f 8e 84 00 00 00    	jle    800a45 <vprintfmt+0x213>
  8009c1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8009c5:	74 7e                	je     800a45 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009cb:	89 34 24             	mov    %esi,(%esp)
  8009ce:	e8 ab 02 00 00       	call   800c7e <strnlen>
  8009d3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009d6:	29 c2                	sub    %eax,%edx
  8009d8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8009db:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009df:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8009e2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8009e5:	89 de                	mov    %ebx,%esi
  8009e7:	89 d3                	mov    %edx,%ebx
  8009e9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009eb:	eb 0b                	jmp    8009f8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8009ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f1:	89 3c 24             	mov    %edi,(%esp)
  8009f4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f7:	4b                   	dec    %ebx
  8009f8:	85 db                	test   %ebx,%ebx
  8009fa:	7f f1                	jg     8009ed <vprintfmt+0x1bb>
  8009fc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8009ff:	89 f3                	mov    %esi,%ebx
  800a01:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800a04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a07:	85 c0                	test   %eax,%eax
  800a09:	79 05                	jns    800a10 <vprintfmt+0x1de>
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a10:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a13:	29 c2                	sub    %eax,%edx
  800a15:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a18:	eb 2b                	jmp    800a45 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a1a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a1e:	74 18                	je     800a38 <vprintfmt+0x206>
  800a20:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a23:	83 fa 5e             	cmp    $0x5e,%edx
  800a26:	76 10                	jbe    800a38 <vprintfmt+0x206>
					putch('?', putdat);
  800a28:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a33:	ff 55 08             	call   *0x8(%ebp)
  800a36:	eb 0a                	jmp    800a42 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800a38:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a3c:	89 04 24             	mov    %eax,(%esp)
  800a3f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a42:	ff 4d e4             	decl   -0x1c(%ebp)
  800a45:	0f be 06             	movsbl (%esi),%eax
  800a48:	46                   	inc    %esi
  800a49:	85 c0                	test   %eax,%eax
  800a4b:	74 21                	je     800a6e <vprintfmt+0x23c>
  800a4d:	85 ff                	test   %edi,%edi
  800a4f:	78 c9                	js     800a1a <vprintfmt+0x1e8>
  800a51:	4f                   	dec    %edi
  800a52:	79 c6                	jns    800a1a <vprintfmt+0x1e8>
  800a54:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a57:	89 de                	mov    %ebx,%esi
  800a59:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a5c:	eb 18                	jmp    800a76 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a5e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a62:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a69:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a6b:	4b                   	dec    %ebx
  800a6c:	eb 08                	jmp    800a76 <vprintfmt+0x244>
  800a6e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a71:	89 de                	mov    %ebx,%esi
  800a73:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a76:	85 db                	test   %ebx,%ebx
  800a78:	7f e4                	jg     800a5e <vprintfmt+0x22c>
  800a7a:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a7d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a82:	e9 ce fd ff ff       	jmp    800855 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a87:	83 f9 01             	cmp    $0x1,%ecx
  800a8a:	7e 10                	jle    800a9c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800a8c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8f:	8d 50 08             	lea    0x8(%eax),%edx
  800a92:	89 55 14             	mov    %edx,0x14(%ebp)
  800a95:	8b 30                	mov    (%eax),%esi
  800a97:	8b 78 04             	mov    0x4(%eax),%edi
  800a9a:	eb 26                	jmp    800ac2 <vprintfmt+0x290>
	else if (lflag)
  800a9c:	85 c9                	test   %ecx,%ecx
  800a9e:	74 12                	je     800ab2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800aa0:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa3:	8d 50 04             	lea    0x4(%eax),%edx
  800aa6:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa9:	8b 30                	mov    (%eax),%esi
  800aab:	89 f7                	mov    %esi,%edi
  800aad:	c1 ff 1f             	sar    $0x1f,%edi
  800ab0:	eb 10                	jmp    800ac2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800ab2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab5:	8d 50 04             	lea    0x4(%eax),%edx
  800ab8:	89 55 14             	mov    %edx,0x14(%ebp)
  800abb:	8b 30                	mov    (%eax),%esi
  800abd:	89 f7                	mov    %esi,%edi
  800abf:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ac2:	85 ff                	test   %edi,%edi
  800ac4:	78 0a                	js     800ad0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ac6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800acb:	e9 ac 00 00 00       	jmp    800b7c <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800ad0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ad4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800adb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ade:	f7 de                	neg    %esi
  800ae0:	83 d7 00             	adc    $0x0,%edi
  800ae3:	f7 df                	neg    %edi
			}
			base = 10;
  800ae5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aea:	e9 8d 00 00 00       	jmp    800b7c <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800aef:	89 ca                	mov    %ecx,%edx
  800af1:	8d 45 14             	lea    0x14(%ebp),%eax
  800af4:	e8 bd fc ff ff       	call   8007b6 <getuint>
  800af9:	89 c6                	mov    %eax,%esi
  800afb:	89 d7                	mov    %edx,%edi
			base = 10;
  800afd:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b02:	eb 78                	jmp    800b7c <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800b04:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b08:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b0f:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800b12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b16:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b1d:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800b20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b24:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b2b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b2e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800b31:	e9 1f fd ff ff       	jmp    800855 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800b36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b3a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b41:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b48:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b4f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b52:	8b 45 14             	mov    0x14(%ebp),%eax
  800b55:	8d 50 04             	lea    0x4(%eax),%edx
  800b58:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b5b:	8b 30                	mov    (%eax),%esi
  800b5d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b62:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b67:	eb 13                	jmp    800b7c <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b69:	89 ca                	mov    %ecx,%edx
  800b6b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b6e:	e8 43 fc ff ff       	call   8007b6 <getuint>
  800b73:	89 c6                	mov    %eax,%esi
  800b75:	89 d7                	mov    %edx,%edi
			base = 16;
  800b77:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b7c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800b80:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b84:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b87:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b8f:	89 34 24             	mov    %esi,(%esp)
  800b92:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b96:	89 da                	mov    %ebx,%edx
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	e8 4c fb ff ff       	call   8006ec <printnum>
			break;
  800ba0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ba3:	e9 ad fc ff ff       	jmp    800855 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ba8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bac:	89 04 24             	mov    %eax,(%esp)
  800baf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bb2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800bb5:	e9 9b fc ff ff       	jmp    800855 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bbe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800bc5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bc8:	eb 01                	jmp    800bcb <vprintfmt+0x399>
  800bca:	4e                   	dec    %esi
  800bcb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bcf:	75 f9                	jne    800bca <vprintfmt+0x398>
  800bd1:	e9 7f fc ff ff       	jmp    800855 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800bd6:	83 c4 4c             	add    $0x4c,%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	83 ec 28             	sub    $0x28,%esp
  800be4:	8b 45 08             	mov    0x8(%ebp),%eax
  800be7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bed:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bf1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bf4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	74 30                	je     800c2f <vsnprintf+0x51>
  800bff:	85 d2                	test   %edx,%edx
  800c01:	7e 33                	jle    800c36 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c03:	8b 45 14             	mov    0x14(%ebp),%eax
  800c06:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c0a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c11:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c18:	c7 04 24 f0 07 80 00 	movl   $0x8007f0,(%esp)
  800c1f:	e8 0e fc ff ff       	call   800832 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c24:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c27:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c2d:	eb 0c                	jmp    800c3b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c34:	eb 05                	jmp    800c3b <vsnprintf+0x5d>
  800c36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c3b:	c9                   	leave  
  800c3c:	c3                   	ret    

00800c3d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c43:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c58:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5b:	89 04 24             	mov    %eax,(%esp)
  800c5e:	e8 7b ff ff ff       	call   800bde <vsnprintf>
	va_end(ap);

	return rc;
}
  800c63:	c9                   	leave  
  800c64:	c3                   	ret    
  800c65:	00 00                	add    %al,(%eax)
	...

00800c68 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c73:	eb 01                	jmp    800c76 <strlen+0xe>
		n++;
  800c75:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c76:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c7a:	75 f9                	jne    800c75 <strlen+0xd>
		n++;
	return n;
}
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800c84:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c87:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8c:	eb 01                	jmp    800c8f <strnlen+0x11>
		n++;
  800c8e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c8f:	39 d0                	cmp    %edx,%eax
  800c91:	74 06                	je     800c99 <strnlen+0x1b>
  800c93:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c97:	75 f5                	jne    800c8e <strnlen+0x10>
		n++;
	return n;
}
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	53                   	push   %ebx
  800c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ca5:	ba 00 00 00 00       	mov    $0x0,%edx
  800caa:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800cad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800cb0:	42                   	inc    %edx
  800cb1:	84 c9                	test   %cl,%cl
  800cb3:	75 f5                	jne    800caa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 08             	sub    $0x8,%esp
  800cbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cc2:	89 1c 24             	mov    %ebx,(%esp)
  800cc5:	e8 9e ff ff ff       	call   800c68 <strlen>
	strcpy(dst + len, src);
  800cca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ccd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cd1:	01 d8                	add    %ebx,%eax
  800cd3:	89 04 24             	mov    %eax,(%esp)
  800cd6:	e8 c0 ff ff ff       	call   800c9b <strcpy>
	return dst;
}
  800cdb:	89 d8                	mov    %ebx,%eax
  800cdd:	83 c4 08             	add    $0x8,%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ceb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cee:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cf1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf6:	eb 0c                	jmp    800d04 <strncpy+0x21>
		*dst++ = *src;
  800cf8:	8a 1a                	mov    (%edx),%bl
  800cfa:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cfd:	80 3a 01             	cmpb   $0x1,(%edx)
  800d00:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d03:	41                   	inc    %ecx
  800d04:	39 f1                	cmp    %esi,%ecx
  800d06:	75 f0                	jne    800cf8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	8b 75 08             	mov    0x8(%ebp),%esi
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d1a:	85 d2                	test   %edx,%edx
  800d1c:	75 0a                	jne    800d28 <strlcpy+0x1c>
  800d1e:	89 f0                	mov    %esi,%eax
  800d20:	eb 1a                	jmp    800d3c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d22:	88 18                	mov    %bl,(%eax)
  800d24:	40                   	inc    %eax
  800d25:	41                   	inc    %ecx
  800d26:	eb 02                	jmp    800d2a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d28:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800d2a:	4a                   	dec    %edx
  800d2b:	74 0a                	je     800d37 <strlcpy+0x2b>
  800d2d:	8a 19                	mov    (%ecx),%bl
  800d2f:	84 db                	test   %bl,%bl
  800d31:	75 ef                	jne    800d22 <strlcpy+0x16>
  800d33:	89 c2                	mov    %eax,%edx
  800d35:	eb 02                	jmp    800d39 <strlcpy+0x2d>
  800d37:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800d39:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d3c:	29 f0                	sub    %esi,%eax
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d48:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d4b:	eb 02                	jmp    800d4f <strcmp+0xd>
		p++, q++;
  800d4d:	41                   	inc    %ecx
  800d4e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d4f:	8a 01                	mov    (%ecx),%al
  800d51:	84 c0                	test   %al,%al
  800d53:	74 04                	je     800d59 <strcmp+0x17>
  800d55:	3a 02                	cmp    (%edx),%al
  800d57:	74 f4                	je     800d4d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d59:	0f b6 c0             	movzbl %al,%eax
  800d5c:	0f b6 12             	movzbl (%edx),%edx
  800d5f:	29 d0                	sub    %edx,%eax
}
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	53                   	push   %ebx
  800d67:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800d70:	eb 03                	jmp    800d75 <strncmp+0x12>
		n--, p++, q++;
  800d72:	4a                   	dec    %edx
  800d73:	40                   	inc    %eax
  800d74:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d75:	85 d2                	test   %edx,%edx
  800d77:	74 14                	je     800d8d <strncmp+0x2a>
  800d79:	8a 18                	mov    (%eax),%bl
  800d7b:	84 db                	test   %bl,%bl
  800d7d:	74 04                	je     800d83 <strncmp+0x20>
  800d7f:	3a 19                	cmp    (%ecx),%bl
  800d81:	74 ef                	je     800d72 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d83:	0f b6 00             	movzbl (%eax),%eax
  800d86:	0f b6 11             	movzbl (%ecx),%edx
  800d89:	29 d0                	sub    %edx,%eax
  800d8b:	eb 05                	jmp    800d92 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d8d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d92:	5b                   	pop    %ebx
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d9e:	eb 05                	jmp    800da5 <strchr+0x10>
		if (*s == c)
  800da0:	38 ca                	cmp    %cl,%dl
  800da2:	74 0c                	je     800db0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800da4:	40                   	inc    %eax
  800da5:	8a 10                	mov    (%eax),%dl
  800da7:	84 d2                	test   %dl,%dl
  800da9:	75 f5                	jne    800da0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800dab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	8b 45 08             	mov    0x8(%ebp),%eax
  800db8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800dbb:	eb 05                	jmp    800dc2 <strfind+0x10>
		if (*s == c)
  800dbd:	38 ca                	cmp    %cl,%dl
  800dbf:	74 07                	je     800dc8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800dc1:	40                   	inc    %eax
  800dc2:	8a 10                	mov    (%eax),%dl
  800dc4:	84 d2                	test   %dl,%dl
  800dc6:	75 f5                	jne    800dbd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800dd9:	85 c9                	test   %ecx,%ecx
  800ddb:	74 30                	je     800e0d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ddd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800de3:	75 25                	jne    800e0a <memset+0x40>
  800de5:	f6 c1 03             	test   $0x3,%cl
  800de8:	75 20                	jne    800e0a <memset+0x40>
		c &= 0xFF;
  800dea:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ded:	89 d3                	mov    %edx,%ebx
  800def:	c1 e3 08             	shl    $0x8,%ebx
  800df2:	89 d6                	mov    %edx,%esi
  800df4:	c1 e6 18             	shl    $0x18,%esi
  800df7:	89 d0                	mov    %edx,%eax
  800df9:	c1 e0 10             	shl    $0x10,%eax
  800dfc:	09 f0                	or     %esi,%eax
  800dfe:	09 d0                	or     %edx,%eax
  800e00:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e02:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e05:	fc                   	cld    
  800e06:	f3 ab                	rep stos %eax,%es:(%edi)
  800e08:	eb 03                	jmp    800e0d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e0a:	fc                   	cld    
  800e0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e0d:	89 f8                	mov    %edi,%eax
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e22:	39 c6                	cmp    %eax,%esi
  800e24:	73 34                	jae    800e5a <memmove+0x46>
  800e26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e29:	39 d0                	cmp    %edx,%eax
  800e2b:	73 2d                	jae    800e5a <memmove+0x46>
		s += n;
		d += n;
  800e2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e30:	f6 c2 03             	test   $0x3,%dl
  800e33:	75 1b                	jne    800e50 <memmove+0x3c>
  800e35:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e3b:	75 13                	jne    800e50 <memmove+0x3c>
  800e3d:	f6 c1 03             	test   $0x3,%cl
  800e40:	75 0e                	jne    800e50 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e42:	83 ef 04             	sub    $0x4,%edi
  800e45:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e48:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e4b:	fd                   	std    
  800e4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e4e:	eb 07                	jmp    800e57 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e50:	4f                   	dec    %edi
  800e51:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e54:	fd                   	std    
  800e55:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e57:	fc                   	cld    
  800e58:	eb 20                	jmp    800e7a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e5a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e60:	75 13                	jne    800e75 <memmove+0x61>
  800e62:	a8 03                	test   $0x3,%al
  800e64:	75 0f                	jne    800e75 <memmove+0x61>
  800e66:	f6 c1 03             	test   $0x3,%cl
  800e69:	75 0a                	jne    800e75 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e6b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e6e:	89 c7                	mov    %eax,%edi
  800e70:	fc                   	cld    
  800e71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e73:	eb 05                	jmp    800e7a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e75:	89 c7                	mov    %eax,%edi
  800e77:	fc                   	cld    
  800e78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e7a:	5e                   	pop    %esi
  800e7b:	5f                   	pop    %edi
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    

00800e7e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e84:	8b 45 10             	mov    0x10(%ebp),%eax
  800e87:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e92:	8b 45 08             	mov    0x8(%ebp),%eax
  800e95:	89 04 24             	mov    %eax,(%esp)
  800e98:	e8 77 ff ff ff       	call   800e14 <memmove>
}
  800e9d:	c9                   	leave  
  800e9e:	c3                   	ret    

00800e9f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	57                   	push   %edi
  800ea3:	56                   	push   %esi
  800ea4:	53                   	push   %ebx
  800ea5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ea8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800eab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eae:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb3:	eb 16                	jmp    800ecb <memcmp+0x2c>
		if (*s1 != *s2)
  800eb5:	8a 04 17             	mov    (%edi,%edx,1),%al
  800eb8:	42                   	inc    %edx
  800eb9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ebd:	38 c8                	cmp    %cl,%al
  800ebf:	74 0a                	je     800ecb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ec1:	0f b6 c0             	movzbl %al,%eax
  800ec4:	0f b6 c9             	movzbl %cl,%ecx
  800ec7:	29 c8                	sub    %ecx,%eax
  800ec9:	eb 09                	jmp    800ed4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ecb:	39 da                	cmp    %ebx,%edx
  800ecd:	75 e6                	jne    800eb5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ecf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	8b 45 08             	mov    0x8(%ebp),%eax
  800edf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ee2:	89 c2                	mov    %eax,%edx
  800ee4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ee7:	eb 05                	jmp    800eee <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ee9:	38 08                	cmp    %cl,(%eax)
  800eeb:	74 05                	je     800ef2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eed:	40                   	inc    %eax
  800eee:	39 d0                	cmp    %edx,%eax
  800ef0:	72 f7                	jb     800ee9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
  800efa:	8b 55 08             	mov    0x8(%ebp),%edx
  800efd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f00:	eb 01                	jmp    800f03 <strtol+0xf>
		s++;
  800f02:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f03:	8a 02                	mov    (%edx),%al
  800f05:	3c 20                	cmp    $0x20,%al
  800f07:	74 f9                	je     800f02 <strtol+0xe>
  800f09:	3c 09                	cmp    $0x9,%al
  800f0b:	74 f5                	je     800f02 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f0d:	3c 2b                	cmp    $0x2b,%al
  800f0f:	75 08                	jne    800f19 <strtol+0x25>
		s++;
  800f11:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f12:	bf 00 00 00 00       	mov    $0x0,%edi
  800f17:	eb 13                	jmp    800f2c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f19:	3c 2d                	cmp    $0x2d,%al
  800f1b:	75 0a                	jne    800f27 <strtol+0x33>
		s++, neg = 1;
  800f1d:	8d 52 01             	lea    0x1(%edx),%edx
  800f20:	bf 01 00 00 00       	mov    $0x1,%edi
  800f25:	eb 05                	jmp    800f2c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f2c:	85 db                	test   %ebx,%ebx
  800f2e:	74 05                	je     800f35 <strtol+0x41>
  800f30:	83 fb 10             	cmp    $0x10,%ebx
  800f33:	75 28                	jne    800f5d <strtol+0x69>
  800f35:	8a 02                	mov    (%edx),%al
  800f37:	3c 30                	cmp    $0x30,%al
  800f39:	75 10                	jne    800f4b <strtol+0x57>
  800f3b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f3f:	75 0a                	jne    800f4b <strtol+0x57>
		s += 2, base = 16;
  800f41:	83 c2 02             	add    $0x2,%edx
  800f44:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f49:	eb 12                	jmp    800f5d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800f4b:	85 db                	test   %ebx,%ebx
  800f4d:	75 0e                	jne    800f5d <strtol+0x69>
  800f4f:	3c 30                	cmp    $0x30,%al
  800f51:	75 05                	jne    800f58 <strtol+0x64>
		s++, base = 8;
  800f53:	42                   	inc    %edx
  800f54:	b3 08                	mov    $0x8,%bl
  800f56:	eb 05                	jmp    800f5d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800f58:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f62:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f64:	8a 0a                	mov    (%edx),%cl
  800f66:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f69:	80 fb 09             	cmp    $0x9,%bl
  800f6c:	77 08                	ja     800f76 <strtol+0x82>
			dig = *s - '0';
  800f6e:	0f be c9             	movsbl %cl,%ecx
  800f71:	83 e9 30             	sub    $0x30,%ecx
  800f74:	eb 1e                	jmp    800f94 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f76:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f79:	80 fb 19             	cmp    $0x19,%bl
  800f7c:	77 08                	ja     800f86 <strtol+0x92>
			dig = *s - 'a' + 10;
  800f7e:	0f be c9             	movsbl %cl,%ecx
  800f81:	83 e9 57             	sub    $0x57,%ecx
  800f84:	eb 0e                	jmp    800f94 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f86:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f89:	80 fb 19             	cmp    $0x19,%bl
  800f8c:	77 12                	ja     800fa0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800f8e:	0f be c9             	movsbl %cl,%ecx
  800f91:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f94:	39 f1                	cmp    %esi,%ecx
  800f96:	7d 0c                	jge    800fa4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800f98:	42                   	inc    %edx
  800f99:	0f af c6             	imul   %esi,%eax
  800f9c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f9e:	eb c4                	jmp    800f64 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800fa0:	89 c1                	mov    %eax,%ecx
  800fa2:	eb 02                	jmp    800fa6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800fa4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800fa6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800faa:	74 05                	je     800fb1 <strtol+0xbd>
		*endptr = (char *) s;
  800fac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800faf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800fb1:	85 ff                	test   %edi,%edi
  800fb3:	74 04                	je     800fb9 <strtol+0xc5>
  800fb5:	89 c8                	mov    %ecx,%eax
  800fb7:	f7 d8                	neg    %eax
}
  800fb9:	5b                   	pop    %ebx
  800fba:	5e                   	pop    %esi
  800fbb:	5f                   	pop    %edi
  800fbc:	5d                   	pop    %ebp
  800fbd:	c3                   	ret    
	...

00800fc0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	57                   	push   %edi
  800fc4:	56                   	push   %esi
  800fc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fce:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd1:	89 c3                	mov    %eax,%ebx
  800fd3:	89 c7                	mov    %eax,%edi
  800fd5:	89 c6                	mov    %eax,%esi
  800fd7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fd9:	5b                   	pop    %ebx
  800fda:	5e                   	pop    %esi
  800fdb:	5f                   	pop    %edi
  800fdc:	5d                   	pop    %ebp
  800fdd:	c3                   	ret    

00800fde <sys_cgetc>:

int
sys_cgetc(void)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	57                   	push   %edi
  800fe2:	56                   	push   %esi
  800fe3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe9:	b8 01 00 00 00       	mov    $0x1,%eax
  800fee:	89 d1                	mov    %edx,%ecx
  800ff0:	89 d3                	mov    %edx,%ebx
  800ff2:	89 d7                	mov    %edx,%edi
  800ff4:	89 d6                	mov    %edx,%esi
  800ff6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5f                   	pop    %edi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    

00800ffd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	57                   	push   %edi
  801001:	56                   	push   %esi
  801002:	53                   	push   %ebx
  801003:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801006:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100b:	b8 03 00 00 00       	mov    $0x3,%eax
  801010:	8b 55 08             	mov    0x8(%ebp),%edx
  801013:	89 cb                	mov    %ecx,%ebx
  801015:	89 cf                	mov    %ecx,%edi
  801017:	89 ce                	mov    %ecx,%esi
  801019:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80101b:	85 c0                	test   %eax,%eax
  80101d:	7e 28                	jle    801047 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801023:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80102a:	00 
  80102b:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  801032:	00 
  801033:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80103a:	00 
  80103b:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  801042:	e8 91 f5 ff ff       	call   8005d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801047:	83 c4 2c             	add    $0x2c,%esp
  80104a:	5b                   	pop    %ebx
  80104b:	5e                   	pop    %esi
  80104c:	5f                   	pop    %edi
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    

0080104f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	57                   	push   %edi
  801053:	56                   	push   %esi
  801054:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801055:	ba 00 00 00 00       	mov    $0x0,%edx
  80105a:	b8 02 00 00 00       	mov    $0x2,%eax
  80105f:	89 d1                	mov    %edx,%ecx
  801061:	89 d3                	mov    %edx,%ebx
  801063:	89 d7                	mov    %edx,%edi
  801065:	89 d6                	mov    %edx,%esi
  801067:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801069:	5b                   	pop    %ebx
  80106a:	5e                   	pop    %esi
  80106b:	5f                   	pop    %edi
  80106c:	5d                   	pop    %ebp
  80106d:	c3                   	ret    

0080106e <sys_yield>:

void
sys_yield(void)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	57                   	push   %edi
  801072:	56                   	push   %esi
  801073:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801074:	ba 00 00 00 00       	mov    $0x0,%edx
  801079:	b8 0b 00 00 00       	mov    $0xb,%eax
  80107e:	89 d1                	mov    %edx,%ecx
  801080:	89 d3                	mov    %edx,%ebx
  801082:	89 d7                	mov    %edx,%edi
  801084:	89 d6                	mov    %edx,%esi
  801086:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801088:	5b                   	pop    %ebx
  801089:	5e                   	pop    %esi
  80108a:	5f                   	pop    %edi
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    

0080108d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	57                   	push   %edi
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
  801093:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801096:	be 00 00 00 00       	mov    $0x0,%esi
  80109b:	b8 04 00 00 00       	mov    $0x4,%eax
  8010a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	89 f7                	mov    %esi,%edi
  8010ab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	7e 28                	jle    8010d9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8010bc:	00 
  8010bd:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  8010c4:	00 
  8010c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010cc:	00 
  8010cd:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  8010d4:	e8 ff f4 ff ff       	call   8005d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010d9:	83 c4 2c             	add    $0x2c,%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5f                   	pop    %edi
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	57                   	push   %edi
  8010e5:	56                   	push   %esi
  8010e6:	53                   	push   %ebx
  8010e7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8010ef:	8b 75 18             	mov    0x18(%ebp),%esi
  8010f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801100:	85 c0                	test   %eax,%eax
  801102:	7e 28                	jle    80112c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801104:	89 44 24 10          	mov    %eax,0x10(%esp)
  801108:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80110f:	00 
  801110:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  801117:	00 
  801118:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80111f:	00 
  801120:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  801127:	e8 ac f4 ff ff       	call   8005d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80112c:	83 c4 2c             	add    $0x2c,%esp
  80112f:	5b                   	pop    %ebx
  801130:	5e                   	pop    %esi
  801131:	5f                   	pop    %edi
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    

00801134 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	57                   	push   %edi
  801138:	56                   	push   %esi
  801139:	53                   	push   %ebx
  80113a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801142:	b8 06 00 00 00       	mov    $0x6,%eax
  801147:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114a:	8b 55 08             	mov    0x8(%ebp),%edx
  80114d:	89 df                	mov    %ebx,%edi
  80114f:	89 de                	mov    %ebx,%esi
  801151:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801153:	85 c0                	test   %eax,%eax
  801155:	7e 28                	jle    80117f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801157:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801162:	00 
  801163:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  80116a:	00 
  80116b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801172:	00 
  801173:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  80117a:	e8 59 f4 ff ff       	call   8005d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80117f:	83 c4 2c             	add    $0x2c,%esp
  801182:	5b                   	pop    %ebx
  801183:	5e                   	pop    %esi
  801184:	5f                   	pop    %edi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	57                   	push   %edi
  80118b:	56                   	push   %esi
  80118c:	53                   	push   %ebx
  80118d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801190:	bb 00 00 00 00       	mov    $0x0,%ebx
  801195:	b8 08 00 00 00       	mov    $0x8,%eax
  80119a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119d:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a0:	89 df                	mov    %ebx,%edi
  8011a2:	89 de                	mov    %ebx,%esi
  8011a4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	7e 28                	jle    8011d2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ae:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8011b5:	00 
  8011b6:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  8011bd:	00 
  8011be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c5:	00 
  8011c6:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  8011cd:	e8 06 f4 ff ff       	call   8005d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011d2:	83 c4 2c             	add    $0x2c,%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	57                   	push   %edi
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e8:	b8 09 00 00 00       	mov    $0x9,%eax
  8011ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f3:	89 df                	mov    %ebx,%edi
  8011f5:	89 de                	mov    %ebx,%esi
  8011f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	7e 28                	jle    801225 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801201:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801208:	00 
  801209:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  801210:	00 
  801211:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801218:	00 
  801219:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  801220:	e8 b3 f3 ff ff       	call   8005d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801225:	83 c4 2c             	add    $0x2c,%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	57                   	push   %edi
  801231:	56                   	push   %esi
  801232:	53                   	push   %ebx
  801233:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801243:	8b 55 08             	mov    0x8(%ebp),%edx
  801246:	89 df                	mov    %ebx,%edi
  801248:	89 de                	mov    %ebx,%esi
  80124a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80124c:	85 c0                	test   %eax,%eax
  80124e:	7e 28                	jle    801278 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801250:	89 44 24 10          	mov    %eax,0x10(%esp)
  801254:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80125b:	00 
  80125c:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  801263:	00 
  801264:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80126b:	00 
  80126c:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  801273:	e8 60 f3 ff ff       	call   8005d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801278:	83 c4 2c             	add    $0x2c,%esp
  80127b:	5b                   	pop    %ebx
  80127c:	5e                   	pop    %esi
  80127d:	5f                   	pop    %edi
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    

00801280 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	57                   	push   %edi
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801286:	be 00 00 00 00       	mov    $0x0,%esi
  80128b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801290:	8b 7d 14             	mov    0x14(%ebp),%edi
  801293:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801299:	8b 55 08             	mov    0x8(%ebp),%edx
  80129c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80129e:	5b                   	pop    %ebx
  80129f:	5e                   	pop    %esi
  8012a0:	5f                   	pop    %edi
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    

008012a3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	57                   	push   %edi
  8012a7:	56                   	push   %esi
  8012a8:	53                   	push   %ebx
  8012a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012b1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b9:	89 cb                	mov    %ecx,%ebx
  8012bb:	89 cf                	mov    %ecx,%edi
  8012bd:	89 ce                	mov    %ecx,%esi
  8012bf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	7e 28                	jle    8012ed <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8012d0:	00 
  8012d1:	c7 44 24 08 1f 29 80 	movl   $0x80291f,0x8(%esp)
  8012d8:	00 
  8012d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012e0:	00 
  8012e1:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  8012e8:	e8 eb f2 ff ff       	call   8005d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012ed:	83 c4 2c             	add    $0x2c,%esp
  8012f0:	5b                   	pop    %ebx
  8012f1:	5e                   	pop    %esi
  8012f2:	5f                   	pop    %edi
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    
  8012f5:	00 00                	add    %al,(%eax)
	...

008012f8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012fe:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  801305:	0f 85 80 00 00 00    	jne    80138b <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  80130b:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801310:	8b 40 48             	mov    0x48(%eax),%eax
  801313:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80131a:	00 
  80131b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801322:	ee 
  801323:	89 04 24             	mov    %eax,(%esp)
  801326:	e8 62 fd ff ff       	call   80108d <sys_page_alloc>
  80132b:	85 c0                	test   %eax,%eax
  80132d:	79 20                	jns    80134f <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  80132f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801333:	c7 44 24 08 4c 29 80 	movl   $0x80294c,0x8(%esp)
  80133a:	00 
  80133b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801342:	00 
  801343:	c7 04 24 a8 29 80 00 	movl   $0x8029a8,(%esp)
  80134a:	e8 89 f2 ff ff       	call   8005d8 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  80134f:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801354:	8b 40 48             	mov    0x48(%eax),%eax
  801357:	c7 44 24 04 98 13 80 	movl   $0x801398,0x4(%esp)
  80135e:	00 
  80135f:	89 04 24             	mov    %eax,(%esp)
  801362:	e8 c6 fe ff ff       	call   80122d <sys_env_set_pgfault_upcall>
  801367:	85 c0                	test   %eax,%eax
  801369:	79 20                	jns    80138b <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  80136b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80136f:	c7 44 24 08 78 29 80 	movl   $0x802978,0x8(%esp)
  801376:	00 
  801377:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  80137e:	00 
  80137f:	c7 04 24 a8 29 80 00 	movl   $0x8029a8,(%esp)
  801386:	e8 4d f2 ff ff       	call   8005d8 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80138b:	8b 45 08             	mov    0x8(%ebp),%eax
  80138e:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  801393:	c9                   	leave  
  801394:	c3                   	ret    
  801395:	00 00                	add    %al,(%eax)
	...

00801398 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801398:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801399:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  80139e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013a0:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  8013a3:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  8013a7:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  8013a9:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  8013ac:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  8013ad:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  8013b0:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  8013b2:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  8013b5:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  8013b6:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  8013b9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8013ba:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8013bb:	c3                   	ret    

008013bc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c2:	05 00 00 00 30       	add    $0x30000000,%eax
  8013c7:	c1 e8 0c             	shr    $0xc,%eax
}
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    

008013cc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8013d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d5:	89 04 24             	mov    %eax,(%esp)
  8013d8:	e8 df ff ff ff       	call   8013bc <fd2num>
  8013dd:	05 20 00 0d 00       	add    $0xd0020,%eax
  8013e2:	c1 e0 0c             	shl    $0xc,%eax
}
  8013e5:	c9                   	leave  
  8013e6:	c3                   	ret    

008013e7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	53                   	push   %ebx
  8013eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013ee:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013f3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013f5:	89 c2                	mov    %eax,%edx
  8013f7:	c1 ea 16             	shr    $0x16,%edx
  8013fa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801401:	f6 c2 01             	test   $0x1,%dl
  801404:	74 11                	je     801417 <fd_alloc+0x30>
  801406:	89 c2                	mov    %eax,%edx
  801408:	c1 ea 0c             	shr    $0xc,%edx
  80140b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801412:	f6 c2 01             	test   $0x1,%dl
  801415:	75 09                	jne    801420 <fd_alloc+0x39>
			*fd_store = fd;
  801417:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801419:	b8 00 00 00 00       	mov    $0x0,%eax
  80141e:	eb 17                	jmp    801437 <fd_alloc+0x50>
  801420:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801425:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80142a:	75 c7                	jne    8013f3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80142c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801432:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801437:	5b                   	pop    %ebx
  801438:	5d                   	pop    %ebp
  801439:	c3                   	ret    

0080143a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801440:	83 f8 1f             	cmp    $0x1f,%eax
  801443:	77 36                	ja     80147b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801445:	05 00 00 0d 00       	add    $0xd0000,%eax
  80144a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80144d:	89 c2                	mov    %eax,%edx
  80144f:	c1 ea 16             	shr    $0x16,%edx
  801452:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801459:	f6 c2 01             	test   $0x1,%dl
  80145c:	74 24                	je     801482 <fd_lookup+0x48>
  80145e:	89 c2                	mov    %eax,%edx
  801460:	c1 ea 0c             	shr    $0xc,%edx
  801463:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80146a:	f6 c2 01             	test   $0x1,%dl
  80146d:	74 1a                	je     801489 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80146f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801472:	89 02                	mov    %eax,(%edx)
	return 0;
  801474:	b8 00 00 00 00       	mov    $0x0,%eax
  801479:	eb 13                	jmp    80148e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80147b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801480:	eb 0c                	jmp    80148e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801482:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801487:	eb 05                	jmp    80148e <fd_lookup+0x54>
  801489:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80148e:	5d                   	pop    %ebp
  80148f:	c3                   	ret    

00801490 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	53                   	push   %ebx
  801494:	83 ec 14             	sub    $0x14,%esp
  801497:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80149a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80149d:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a2:	eb 0e                	jmp    8014b2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8014a4:	39 08                	cmp    %ecx,(%eax)
  8014a6:	75 09                	jne    8014b1 <dev_lookup+0x21>
			*dev = devtab[i];
  8014a8:	89 03                	mov    %eax,(%ebx)
			return 0;
  8014aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8014af:	eb 33                	jmp    8014e4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014b1:	42                   	inc    %edx
  8014b2:	8b 04 95 38 2a 80 00 	mov    0x802a38(,%edx,4),%eax
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	75 e7                	jne    8014a4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014bd:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8014c2:	8b 40 48             	mov    0x48(%eax),%eax
  8014c5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cd:	c7 04 24 b8 29 80 00 	movl   $0x8029b8,(%esp)
  8014d4:	e8 f7 f1 ff ff       	call   8006d0 <cprintf>
	*dev = 0;
  8014d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8014df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014e4:	83 c4 14             	add    $0x14,%esp
  8014e7:	5b                   	pop    %ebx
  8014e8:	5d                   	pop    %ebp
  8014e9:	c3                   	ret    

008014ea <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	56                   	push   %esi
  8014ee:	53                   	push   %ebx
  8014ef:	83 ec 30             	sub    $0x30,%esp
  8014f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f5:	8a 45 0c             	mov    0xc(%ebp),%al
  8014f8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014fb:	89 34 24             	mov    %esi,(%esp)
  8014fe:	e8 b9 fe ff ff       	call   8013bc <fd2num>
  801503:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801506:	89 54 24 04          	mov    %edx,0x4(%esp)
  80150a:	89 04 24             	mov    %eax,(%esp)
  80150d:	e8 28 ff ff ff       	call   80143a <fd_lookup>
  801512:	89 c3                	mov    %eax,%ebx
  801514:	85 c0                	test   %eax,%eax
  801516:	78 05                	js     80151d <fd_close+0x33>
	    || fd != fd2)
  801518:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80151b:	74 0d                	je     80152a <fd_close+0x40>
		return (must_exist ? r : 0);
  80151d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801521:	75 46                	jne    801569 <fd_close+0x7f>
  801523:	bb 00 00 00 00       	mov    $0x0,%ebx
  801528:	eb 3f                	jmp    801569 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80152a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801531:	8b 06                	mov    (%esi),%eax
  801533:	89 04 24             	mov    %eax,(%esp)
  801536:	e8 55 ff ff ff       	call   801490 <dev_lookup>
  80153b:	89 c3                	mov    %eax,%ebx
  80153d:	85 c0                	test   %eax,%eax
  80153f:	78 18                	js     801559 <fd_close+0x6f>
		if (dev->dev_close)
  801541:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801544:	8b 40 10             	mov    0x10(%eax),%eax
  801547:	85 c0                	test   %eax,%eax
  801549:	74 09                	je     801554 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80154b:	89 34 24             	mov    %esi,(%esp)
  80154e:	ff d0                	call   *%eax
  801550:	89 c3                	mov    %eax,%ebx
  801552:	eb 05                	jmp    801559 <fd_close+0x6f>
		else
			r = 0;
  801554:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801559:	89 74 24 04          	mov    %esi,0x4(%esp)
  80155d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801564:	e8 cb fb ff ff       	call   801134 <sys_page_unmap>
	return r;
}
  801569:	89 d8                	mov    %ebx,%eax
  80156b:	83 c4 30             	add    $0x30,%esp
  80156e:	5b                   	pop    %ebx
  80156f:	5e                   	pop    %esi
  801570:	5d                   	pop    %ebp
  801571:	c3                   	ret    

00801572 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
  801575:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801578:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157f:	8b 45 08             	mov    0x8(%ebp),%eax
  801582:	89 04 24             	mov    %eax,(%esp)
  801585:	e8 b0 fe ff ff       	call   80143a <fd_lookup>
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 13                	js     8015a1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80158e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801595:	00 
  801596:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801599:	89 04 24             	mov    %eax,(%esp)
  80159c:	e8 49 ff ff ff       	call   8014ea <fd_close>
}
  8015a1:	c9                   	leave  
  8015a2:	c3                   	ret    

008015a3 <close_all>:

void
close_all(void)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015aa:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015af:	89 1c 24             	mov    %ebx,(%esp)
  8015b2:	e8 bb ff ff ff       	call   801572 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015b7:	43                   	inc    %ebx
  8015b8:	83 fb 20             	cmp    $0x20,%ebx
  8015bb:	75 f2                	jne    8015af <close_all+0xc>
		close(i);
}
  8015bd:	83 c4 14             	add    $0x14,%esp
  8015c0:	5b                   	pop    %ebx
  8015c1:	5d                   	pop    %ebp
  8015c2:	c3                   	ret    

008015c3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	57                   	push   %edi
  8015c7:	56                   	push   %esi
  8015c8:	53                   	push   %ebx
  8015c9:	83 ec 4c             	sub    $0x4c,%esp
  8015cc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d9:	89 04 24             	mov    %eax,(%esp)
  8015dc:	e8 59 fe ff ff       	call   80143a <fd_lookup>
  8015e1:	89 c3                	mov    %eax,%ebx
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	0f 88 e1 00 00 00    	js     8016cc <dup+0x109>
		return r;
	close(newfdnum);
  8015eb:	89 3c 24             	mov    %edi,(%esp)
  8015ee:	e8 7f ff ff ff       	call   801572 <close>

	newfd = INDEX2FD(newfdnum);
  8015f3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8015f9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8015fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015ff:	89 04 24             	mov    %eax,(%esp)
  801602:	e8 c5 fd ff ff       	call   8013cc <fd2data>
  801607:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801609:	89 34 24             	mov    %esi,(%esp)
  80160c:	e8 bb fd ff ff       	call   8013cc <fd2data>
  801611:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801614:	89 d8                	mov    %ebx,%eax
  801616:	c1 e8 16             	shr    $0x16,%eax
  801619:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801620:	a8 01                	test   $0x1,%al
  801622:	74 46                	je     80166a <dup+0xa7>
  801624:	89 d8                	mov    %ebx,%eax
  801626:	c1 e8 0c             	shr    $0xc,%eax
  801629:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801630:	f6 c2 01             	test   $0x1,%dl
  801633:	74 35                	je     80166a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801635:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80163c:	25 07 0e 00 00       	and    $0xe07,%eax
  801641:	89 44 24 10          	mov    %eax,0x10(%esp)
  801645:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801648:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80164c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801653:	00 
  801654:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801658:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80165f:	e8 7d fa ff ff       	call   8010e1 <sys_page_map>
  801664:	89 c3                	mov    %eax,%ebx
  801666:	85 c0                	test   %eax,%eax
  801668:	78 3b                	js     8016a5 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80166a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80166d:	89 c2                	mov    %eax,%edx
  80166f:	c1 ea 0c             	shr    $0xc,%edx
  801672:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801679:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80167f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801683:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801687:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80168e:	00 
  80168f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801693:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80169a:	e8 42 fa ff ff       	call   8010e1 <sys_page_map>
  80169f:	89 c3                	mov    %eax,%ebx
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	79 25                	jns    8016ca <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016b0:	e8 7f fa ff ff       	call   801134 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016c3:	e8 6c fa ff ff       	call   801134 <sys_page_unmap>
	return r;
  8016c8:	eb 02                	jmp    8016cc <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8016ca:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016cc:	89 d8                	mov    %ebx,%eax
  8016ce:	83 c4 4c             	add    $0x4c,%esp
  8016d1:	5b                   	pop    %ebx
  8016d2:	5e                   	pop    %esi
  8016d3:	5f                   	pop    %edi
  8016d4:	5d                   	pop    %ebp
  8016d5:	c3                   	ret    

008016d6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 24             	sub    $0x24,%esp
  8016dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e7:	89 1c 24             	mov    %ebx,(%esp)
  8016ea:	e8 4b fd ff ff       	call   80143a <fd_lookup>
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	78 6d                	js     801760 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fd:	8b 00                	mov    (%eax),%eax
  8016ff:	89 04 24             	mov    %eax,(%esp)
  801702:	e8 89 fd ff ff       	call   801490 <dev_lookup>
  801707:	85 c0                	test   %eax,%eax
  801709:	78 55                	js     801760 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80170b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170e:	8b 50 08             	mov    0x8(%eax),%edx
  801711:	83 e2 03             	and    $0x3,%edx
  801714:	83 fa 01             	cmp    $0x1,%edx
  801717:	75 23                	jne    80173c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801719:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80171e:	8b 40 48             	mov    0x48(%eax),%eax
  801721:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801725:	89 44 24 04          	mov    %eax,0x4(%esp)
  801729:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  801730:	e8 9b ef ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  801735:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80173a:	eb 24                	jmp    801760 <read+0x8a>
	}
	if (!dev->dev_read)
  80173c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80173f:	8b 52 08             	mov    0x8(%edx),%edx
  801742:	85 d2                	test   %edx,%edx
  801744:	74 15                	je     80175b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801746:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801749:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80174d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801750:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801754:	89 04 24             	mov    %eax,(%esp)
  801757:	ff d2                	call   *%edx
  801759:	eb 05                	jmp    801760 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80175b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801760:	83 c4 24             	add    $0x24,%esp
  801763:	5b                   	pop    %ebx
  801764:	5d                   	pop    %ebp
  801765:	c3                   	ret    

00801766 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	57                   	push   %edi
  80176a:	56                   	push   %esi
  80176b:	53                   	push   %ebx
  80176c:	83 ec 1c             	sub    $0x1c,%esp
  80176f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801772:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801775:	bb 00 00 00 00       	mov    $0x0,%ebx
  80177a:	eb 23                	jmp    80179f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80177c:	89 f0                	mov    %esi,%eax
  80177e:	29 d8                	sub    %ebx,%eax
  801780:	89 44 24 08          	mov    %eax,0x8(%esp)
  801784:	8b 45 0c             	mov    0xc(%ebp),%eax
  801787:	01 d8                	add    %ebx,%eax
  801789:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178d:	89 3c 24             	mov    %edi,(%esp)
  801790:	e8 41 ff ff ff       	call   8016d6 <read>
		if (m < 0)
  801795:	85 c0                	test   %eax,%eax
  801797:	78 10                	js     8017a9 <readn+0x43>
			return m;
		if (m == 0)
  801799:	85 c0                	test   %eax,%eax
  80179b:	74 0a                	je     8017a7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80179d:	01 c3                	add    %eax,%ebx
  80179f:	39 f3                	cmp    %esi,%ebx
  8017a1:	72 d9                	jb     80177c <readn+0x16>
  8017a3:	89 d8                	mov    %ebx,%eax
  8017a5:	eb 02                	jmp    8017a9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8017a7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8017a9:	83 c4 1c             	add    $0x1c,%esp
  8017ac:	5b                   	pop    %ebx
  8017ad:	5e                   	pop    %esi
  8017ae:	5f                   	pop    %edi
  8017af:	5d                   	pop    %ebp
  8017b0:	c3                   	ret    

008017b1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	53                   	push   %ebx
  8017b5:	83 ec 24             	sub    $0x24,%esp
  8017b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c2:	89 1c 24             	mov    %ebx,(%esp)
  8017c5:	e8 70 fc ff ff       	call   80143a <fd_lookup>
  8017ca:	85 c0                	test   %eax,%eax
  8017cc:	78 68                	js     801836 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d8:	8b 00                	mov    (%eax),%eax
  8017da:	89 04 24             	mov    %eax,(%esp)
  8017dd:	e8 ae fc ff ff       	call   801490 <dev_lookup>
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 50                	js     801836 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017ed:	75 23                	jne    801812 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017ef:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8017f4:	8b 40 48             	mov    0x48(%eax),%eax
  8017f7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ff:	c7 04 24 18 2a 80 00 	movl   $0x802a18,(%esp)
  801806:	e8 c5 ee ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  80180b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801810:	eb 24                	jmp    801836 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801812:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801815:	8b 52 0c             	mov    0xc(%edx),%edx
  801818:	85 d2                	test   %edx,%edx
  80181a:	74 15                	je     801831 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80181c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80181f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801823:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801826:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80182a:	89 04 24             	mov    %eax,(%esp)
  80182d:	ff d2                	call   *%edx
  80182f:	eb 05                	jmp    801836 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801831:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801836:	83 c4 24             	add    $0x24,%esp
  801839:	5b                   	pop    %ebx
  80183a:	5d                   	pop    %ebp
  80183b:	c3                   	ret    

0080183c <seek>:

int
seek(int fdnum, off_t offset)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801842:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801845:	89 44 24 04          	mov    %eax,0x4(%esp)
  801849:	8b 45 08             	mov    0x8(%ebp),%eax
  80184c:	89 04 24             	mov    %eax,(%esp)
  80184f:	e8 e6 fb ff ff       	call   80143a <fd_lookup>
  801854:	85 c0                	test   %eax,%eax
  801856:	78 0e                	js     801866 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801858:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80185b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80185e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801861:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	53                   	push   %ebx
  80186c:	83 ec 24             	sub    $0x24,%esp
  80186f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801872:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801875:	89 44 24 04          	mov    %eax,0x4(%esp)
  801879:	89 1c 24             	mov    %ebx,(%esp)
  80187c:	e8 b9 fb ff ff       	call   80143a <fd_lookup>
  801881:	85 c0                	test   %eax,%eax
  801883:	78 61                	js     8018e6 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801885:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801888:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188f:	8b 00                	mov    (%eax),%eax
  801891:	89 04 24             	mov    %eax,(%esp)
  801894:	e8 f7 fb ff ff       	call   801490 <dev_lookup>
  801899:	85 c0                	test   %eax,%eax
  80189b:	78 49                	js     8018e6 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80189d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018a4:	75 23                	jne    8018c9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018a6:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018ab:	8b 40 48             	mov    0x48(%eax),%eax
  8018ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b6:	c7 04 24 d8 29 80 00 	movl   $0x8029d8,(%esp)
  8018bd:	e8 0e ee ff ff       	call   8006d0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018c7:	eb 1d                	jmp    8018e6 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8018c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018cc:	8b 52 18             	mov    0x18(%edx),%edx
  8018cf:	85 d2                	test   %edx,%edx
  8018d1:	74 0e                	je     8018e1 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018d6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018da:	89 04 24             	mov    %eax,(%esp)
  8018dd:	ff d2                	call   *%edx
  8018df:	eb 05                	jmp    8018e6 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018e6:	83 c4 24             	add    $0x24,%esp
  8018e9:	5b                   	pop    %ebx
  8018ea:	5d                   	pop    %ebp
  8018eb:	c3                   	ret    

008018ec <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	53                   	push   %ebx
  8018f0:	83 ec 24             	sub    $0x24,%esp
  8018f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801900:	89 04 24             	mov    %eax,(%esp)
  801903:	e8 32 fb ff ff       	call   80143a <fd_lookup>
  801908:	85 c0                	test   %eax,%eax
  80190a:	78 52                	js     80195e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80190c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801913:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801916:	8b 00                	mov    (%eax),%eax
  801918:	89 04 24             	mov    %eax,(%esp)
  80191b:	e8 70 fb ff ff       	call   801490 <dev_lookup>
  801920:	85 c0                	test   %eax,%eax
  801922:	78 3a                	js     80195e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801924:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801927:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80192b:	74 2c                	je     801959 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80192d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801930:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801937:	00 00 00 
	stat->st_isdir = 0;
  80193a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801941:	00 00 00 
	stat->st_dev = dev;
  801944:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80194a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80194e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801951:	89 14 24             	mov    %edx,(%esp)
  801954:	ff 50 14             	call   *0x14(%eax)
  801957:	eb 05                	jmp    80195e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801959:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80195e:	83 c4 24             	add    $0x24,%esp
  801961:	5b                   	pop    %ebx
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    

00801964 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	56                   	push   %esi
  801968:	53                   	push   %ebx
  801969:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80196c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801973:	00 
  801974:	8b 45 08             	mov    0x8(%ebp),%eax
  801977:	89 04 24             	mov    %eax,(%esp)
  80197a:	e8 fe 01 00 00       	call   801b7d <open>
  80197f:	89 c3                	mov    %eax,%ebx
  801981:	85 c0                	test   %eax,%eax
  801983:	78 1b                	js     8019a0 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801985:	8b 45 0c             	mov    0xc(%ebp),%eax
  801988:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198c:	89 1c 24             	mov    %ebx,(%esp)
  80198f:	e8 58 ff ff ff       	call   8018ec <fstat>
  801994:	89 c6                	mov    %eax,%esi
	close(fd);
  801996:	89 1c 24             	mov    %ebx,(%esp)
  801999:	e8 d4 fb ff ff       	call   801572 <close>
	return r;
  80199e:	89 f3                	mov    %esi,%ebx
}
  8019a0:	89 d8                	mov    %ebx,%eax
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	5b                   	pop    %ebx
  8019a6:	5e                   	pop    %esi
  8019a7:	5d                   	pop    %ebp
  8019a8:	c3                   	ret    
  8019a9:	00 00                	add    %al,(%eax)
	...

008019ac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	56                   	push   %esi
  8019b0:	53                   	push   %ebx
  8019b1:	83 ec 10             	sub    $0x10,%esp
  8019b4:	89 c3                	mov    %eax,%ebx
  8019b6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8019b8:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  8019bf:	75 11                	jne    8019d2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019c8:	e8 38 08 00 00       	call   802205 <ipc_find_env>
  8019cd:	a3 ac 40 80 00       	mov    %eax,0x8040ac
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019d2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019d9:	00 
  8019da:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8019e1:	00 
  8019e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019e6:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  8019eb:	89 04 24             	mov    %eax,(%esp)
  8019ee:	e8 a8 07 00 00       	call   80219b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019fa:	00 
  8019fb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a06:	e8 29 07 00 00       	call   802134 <ipc_recv>
}
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	5b                   	pop    %ebx
  801a0f:	5e                   	pop    %esi
  801a10:	5d                   	pop    %ebp
  801a11:	c3                   	ret    

00801a12 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a18:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a1e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a26:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a30:	b8 02 00 00 00       	mov    $0x2,%eax
  801a35:	e8 72 ff ff ff       	call   8019ac <fsipc>
}
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    

00801a3c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a42:	8b 45 08             	mov    0x8(%ebp),%eax
  801a45:	8b 40 0c             	mov    0xc(%eax),%eax
  801a48:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a52:	b8 06 00 00 00       	mov    $0x6,%eax
  801a57:	e8 50 ff ff ff       	call   8019ac <fsipc>
}
  801a5c:	c9                   	leave  
  801a5d:	c3                   	ret    

00801a5e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	53                   	push   %ebx
  801a62:	83 ec 14             	sub    $0x14,%esp
  801a65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a68:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a73:	ba 00 00 00 00       	mov    $0x0,%edx
  801a78:	b8 05 00 00 00       	mov    $0x5,%eax
  801a7d:	e8 2a ff ff ff       	call   8019ac <fsipc>
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 2b                	js     801ab1 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a86:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a8d:	00 
  801a8e:	89 1c 24             	mov    %ebx,(%esp)
  801a91:	e8 05 f2 ff ff       	call   800c9b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a96:	a1 80 50 80 00       	mov    0x805080,%eax
  801a9b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801aa1:	a1 84 50 80 00       	mov    0x805084,%eax
  801aa6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ab1:	83 c4 14             	add    $0x14,%esp
  801ab4:	5b                   	pop    %ebx
  801ab5:	5d                   	pop    %ebp
  801ab6:	c3                   	ret    

00801ab7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801abd:	c7 44 24 08 48 2a 80 	movl   $0x802a48,0x8(%esp)
  801ac4:	00 
  801ac5:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801acc:	00 
  801acd:	c7 04 24 66 2a 80 00 	movl   $0x802a66,(%esp)
  801ad4:	e8 ff ea ff ff       	call   8005d8 <_panic>

00801ad9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	56                   	push   %esi
  801add:	53                   	push   %ebx
  801ade:	83 ec 10             	sub    $0x10,%esp
  801ae1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae7:	8b 40 0c             	mov    0xc(%eax),%eax
  801aea:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801aef:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801af5:	ba 00 00 00 00       	mov    $0x0,%edx
  801afa:	b8 03 00 00 00       	mov    $0x3,%eax
  801aff:	e8 a8 fe ff ff       	call   8019ac <fsipc>
  801b04:	89 c3                	mov    %eax,%ebx
  801b06:	85 c0                	test   %eax,%eax
  801b08:	78 6a                	js     801b74 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b0a:	39 c6                	cmp    %eax,%esi
  801b0c:	73 24                	jae    801b32 <devfile_read+0x59>
  801b0e:	c7 44 24 0c 71 2a 80 	movl   $0x802a71,0xc(%esp)
  801b15:	00 
  801b16:	c7 44 24 08 78 2a 80 	movl   $0x802a78,0x8(%esp)
  801b1d:	00 
  801b1e:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b25:	00 
  801b26:	c7 04 24 66 2a 80 00 	movl   $0x802a66,(%esp)
  801b2d:	e8 a6 ea ff ff       	call   8005d8 <_panic>
	assert(r <= PGSIZE);
  801b32:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b37:	7e 24                	jle    801b5d <devfile_read+0x84>
  801b39:	c7 44 24 0c 8d 2a 80 	movl   $0x802a8d,0xc(%esp)
  801b40:	00 
  801b41:	c7 44 24 08 78 2a 80 	movl   $0x802a78,0x8(%esp)
  801b48:	00 
  801b49:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b50:	00 
  801b51:	c7 04 24 66 2a 80 00 	movl   $0x802a66,(%esp)
  801b58:	e8 7b ea ff ff       	call   8005d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b5d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b61:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b68:	00 
  801b69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6c:	89 04 24             	mov    %eax,(%esp)
  801b6f:	e8 a0 f2 ff ff       	call   800e14 <memmove>
	return r;
}
  801b74:	89 d8                	mov    %ebx,%eax
  801b76:	83 c4 10             	add    $0x10,%esp
  801b79:	5b                   	pop    %ebx
  801b7a:	5e                   	pop    %esi
  801b7b:	5d                   	pop    %ebp
  801b7c:	c3                   	ret    

00801b7d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	56                   	push   %esi
  801b81:	53                   	push   %ebx
  801b82:	83 ec 20             	sub    $0x20,%esp
  801b85:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b88:	89 34 24             	mov    %esi,(%esp)
  801b8b:	e8 d8 f0 ff ff       	call   800c68 <strlen>
  801b90:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b95:	7f 60                	jg     801bf7 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9a:	89 04 24             	mov    %eax,(%esp)
  801b9d:	e8 45 f8 ff ff       	call   8013e7 <fd_alloc>
  801ba2:	89 c3                	mov    %eax,%ebx
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	78 54                	js     801bfc <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ba8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bac:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801bb3:	e8 e3 f0 ff ff       	call   800c9b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bbb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bc0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc3:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc8:	e8 df fd ff ff       	call   8019ac <fsipc>
  801bcd:	89 c3                	mov    %eax,%ebx
  801bcf:	85 c0                	test   %eax,%eax
  801bd1:	79 15                	jns    801be8 <open+0x6b>
		fd_close(fd, 0);
  801bd3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bda:	00 
  801bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bde:	89 04 24             	mov    %eax,(%esp)
  801be1:	e8 04 f9 ff ff       	call   8014ea <fd_close>
		return r;
  801be6:	eb 14                	jmp    801bfc <open+0x7f>
	}

	return fd2num(fd);
  801be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801beb:	89 04 24             	mov    %eax,(%esp)
  801bee:	e8 c9 f7 ff ff       	call   8013bc <fd2num>
  801bf3:	89 c3                	mov    %eax,%ebx
  801bf5:	eb 05                	jmp    801bfc <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bf7:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bfc:	89 d8                	mov    %ebx,%eax
  801bfe:	83 c4 20             	add    $0x20,%esp
  801c01:	5b                   	pop    %ebx
  801c02:	5e                   	pop    %esi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    

00801c05 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c10:	b8 08 00 00 00       	mov    $0x8,%eax
  801c15:	e8 92 fd ff ff       	call   8019ac <fsipc>
}
  801c1a:	c9                   	leave  
  801c1b:	c3                   	ret    

00801c1c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	56                   	push   %esi
  801c20:	53                   	push   %ebx
  801c21:	83 ec 10             	sub    $0x10,%esp
  801c24:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c27:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2a:	89 04 24             	mov    %eax,(%esp)
  801c2d:	e8 9a f7 ff ff       	call   8013cc <fd2data>
  801c32:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c34:	c7 44 24 04 99 2a 80 	movl   $0x802a99,0x4(%esp)
  801c3b:	00 
  801c3c:	89 34 24             	mov    %esi,(%esp)
  801c3f:	e8 57 f0 ff ff       	call   800c9b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c44:	8b 43 04             	mov    0x4(%ebx),%eax
  801c47:	2b 03                	sub    (%ebx),%eax
  801c49:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c4f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c56:	00 00 00 
	stat->st_dev = &devpipe;
  801c59:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801c60:	30 80 00 
	return 0;
}
  801c63:	b8 00 00 00 00       	mov    $0x0,%eax
  801c68:	83 c4 10             	add    $0x10,%esp
  801c6b:	5b                   	pop    %ebx
  801c6c:	5e                   	pop    %esi
  801c6d:	5d                   	pop    %ebp
  801c6e:	c3                   	ret    

00801c6f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	53                   	push   %ebx
  801c73:	83 ec 14             	sub    $0x14,%esp
  801c76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c79:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c84:	e8 ab f4 ff ff       	call   801134 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c89:	89 1c 24             	mov    %ebx,(%esp)
  801c8c:	e8 3b f7 ff ff       	call   8013cc <fd2data>
  801c91:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c9c:	e8 93 f4 ff ff       	call   801134 <sys_page_unmap>
}
  801ca1:	83 c4 14             	add    $0x14,%esp
  801ca4:	5b                   	pop    %ebx
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    

00801ca7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	57                   	push   %edi
  801cab:	56                   	push   %esi
  801cac:	53                   	push   %ebx
  801cad:	83 ec 2c             	sub    $0x2c,%esp
  801cb0:	89 c7                	mov    %eax,%edi
  801cb2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cb5:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801cba:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cbd:	89 3c 24             	mov    %edi,(%esp)
  801cc0:	e8 87 05 00 00       	call   80224c <pageref>
  801cc5:	89 c6                	mov    %eax,%esi
  801cc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cca:	89 04 24             	mov    %eax,(%esp)
  801ccd:	e8 7a 05 00 00       	call   80224c <pageref>
  801cd2:	39 c6                	cmp    %eax,%esi
  801cd4:	0f 94 c0             	sete   %al
  801cd7:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801cda:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801ce0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ce3:	39 cb                	cmp    %ecx,%ebx
  801ce5:	75 08                	jne    801cef <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ce7:	83 c4 2c             	add    $0x2c,%esp
  801cea:	5b                   	pop    %ebx
  801ceb:	5e                   	pop    %esi
  801cec:	5f                   	pop    %edi
  801ced:	5d                   	pop    %ebp
  801cee:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801cef:	83 f8 01             	cmp    $0x1,%eax
  801cf2:	75 c1                	jne    801cb5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cf4:	8b 42 58             	mov    0x58(%edx),%eax
  801cf7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801cfe:	00 
  801cff:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d07:	c7 04 24 a0 2a 80 00 	movl   $0x802aa0,(%esp)
  801d0e:	e8 bd e9 ff ff       	call   8006d0 <cprintf>
  801d13:	eb a0                	jmp    801cb5 <_pipeisclosed+0xe>

00801d15 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	57                   	push   %edi
  801d19:	56                   	push   %esi
  801d1a:	53                   	push   %ebx
  801d1b:	83 ec 1c             	sub    $0x1c,%esp
  801d1e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d21:	89 34 24             	mov    %esi,(%esp)
  801d24:	e8 a3 f6 ff ff       	call   8013cc <fd2data>
  801d29:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d2b:	bf 00 00 00 00       	mov    $0x0,%edi
  801d30:	eb 3c                	jmp    801d6e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d32:	89 da                	mov    %ebx,%edx
  801d34:	89 f0                	mov    %esi,%eax
  801d36:	e8 6c ff ff ff       	call   801ca7 <_pipeisclosed>
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	75 38                	jne    801d77 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d3f:	e8 2a f3 ff ff       	call   80106e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d44:	8b 43 04             	mov    0x4(%ebx),%eax
  801d47:	8b 13                	mov    (%ebx),%edx
  801d49:	83 c2 20             	add    $0x20,%edx
  801d4c:	39 d0                	cmp    %edx,%eax
  801d4e:	73 e2                	jae    801d32 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d50:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d53:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d56:	89 c2                	mov    %eax,%edx
  801d58:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d5e:	79 05                	jns    801d65 <devpipe_write+0x50>
  801d60:	4a                   	dec    %edx
  801d61:	83 ca e0             	or     $0xffffffe0,%edx
  801d64:	42                   	inc    %edx
  801d65:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d69:	40                   	inc    %eax
  801d6a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d6d:	47                   	inc    %edi
  801d6e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d71:	75 d1                	jne    801d44 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d73:	89 f8                	mov    %edi,%eax
  801d75:	eb 05                	jmp    801d7c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d77:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d7c:	83 c4 1c             	add    $0x1c,%esp
  801d7f:	5b                   	pop    %ebx
  801d80:	5e                   	pop    %esi
  801d81:	5f                   	pop    %edi
  801d82:	5d                   	pop    %ebp
  801d83:	c3                   	ret    

00801d84 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	57                   	push   %edi
  801d88:	56                   	push   %esi
  801d89:	53                   	push   %ebx
  801d8a:	83 ec 1c             	sub    $0x1c,%esp
  801d8d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d90:	89 3c 24             	mov    %edi,(%esp)
  801d93:	e8 34 f6 ff ff       	call   8013cc <fd2data>
  801d98:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d9a:	be 00 00 00 00       	mov    $0x0,%esi
  801d9f:	eb 3a                	jmp    801ddb <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801da1:	85 f6                	test   %esi,%esi
  801da3:	74 04                	je     801da9 <devpipe_read+0x25>
				return i;
  801da5:	89 f0                	mov    %esi,%eax
  801da7:	eb 40                	jmp    801de9 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801da9:	89 da                	mov    %ebx,%edx
  801dab:	89 f8                	mov    %edi,%eax
  801dad:	e8 f5 fe ff ff       	call   801ca7 <_pipeisclosed>
  801db2:	85 c0                	test   %eax,%eax
  801db4:	75 2e                	jne    801de4 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801db6:	e8 b3 f2 ff ff       	call   80106e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dbb:	8b 03                	mov    (%ebx),%eax
  801dbd:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dc0:	74 df                	je     801da1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dc2:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801dc7:	79 05                	jns    801dce <devpipe_read+0x4a>
  801dc9:	48                   	dec    %eax
  801dca:	83 c8 e0             	or     $0xffffffe0,%eax
  801dcd:	40                   	inc    %eax
  801dce:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801dd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd5:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801dd8:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dda:	46                   	inc    %esi
  801ddb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dde:	75 db                	jne    801dbb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801de0:	89 f0                	mov    %esi,%eax
  801de2:	eb 05                	jmp    801de9 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801de4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801de9:	83 c4 1c             	add    $0x1c,%esp
  801dec:	5b                   	pop    %ebx
  801ded:	5e                   	pop    %esi
  801dee:	5f                   	pop    %edi
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    

00801df1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	57                   	push   %edi
  801df5:	56                   	push   %esi
  801df6:	53                   	push   %ebx
  801df7:	83 ec 3c             	sub    $0x3c,%esp
  801dfa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801dfd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e00:	89 04 24             	mov    %eax,(%esp)
  801e03:	e8 df f5 ff ff       	call   8013e7 <fd_alloc>
  801e08:	89 c3                	mov    %eax,%ebx
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	0f 88 45 01 00 00    	js     801f57 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e12:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e19:	00 
  801e1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e28:	e8 60 f2 ff ff       	call   80108d <sys_page_alloc>
  801e2d:	89 c3                	mov    %eax,%ebx
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	0f 88 20 01 00 00    	js     801f57 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e37:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e3a:	89 04 24             	mov    %eax,(%esp)
  801e3d:	e8 a5 f5 ff ff       	call   8013e7 <fd_alloc>
  801e42:	89 c3                	mov    %eax,%ebx
  801e44:	85 c0                	test   %eax,%eax
  801e46:	0f 88 f8 00 00 00    	js     801f44 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e4c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e53:	00 
  801e54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e62:	e8 26 f2 ff ff       	call   80108d <sys_page_alloc>
  801e67:	89 c3                	mov    %eax,%ebx
  801e69:	85 c0                	test   %eax,%eax
  801e6b:	0f 88 d3 00 00 00    	js     801f44 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e74:	89 04 24             	mov    %eax,(%esp)
  801e77:	e8 50 f5 ff ff       	call   8013cc <fd2data>
  801e7c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e85:	00 
  801e86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e91:	e8 f7 f1 ff ff       	call   80108d <sys_page_alloc>
  801e96:	89 c3                	mov    %eax,%ebx
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	0f 88 91 00 00 00    	js     801f31 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ea3:	89 04 24             	mov    %eax,(%esp)
  801ea6:	e8 21 f5 ff ff       	call   8013cc <fd2data>
  801eab:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801eb2:	00 
  801eb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eb7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ebe:	00 
  801ebf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ec3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eca:	e8 12 f2 ff ff       	call   8010e1 <sys_page_map>
  801ecf:	89 c3                	mov    %eax,%ebx
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	78 4c                	js     801f21 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ed5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801edb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ede:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ee0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ee3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801eea:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ef0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ef3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ef5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ef8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801eff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f02:	89 04 24             	mov    %eax,(%esp)
  801f05:	e8 b2 f4 ff ff       	call   8013bc <fd2num>
  801f0a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801f0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f0f:	89 04 24             	mov    %eax,(%esp)
  801f12:	e8 a5 f4 ff ff       	call   8013bc <fd2num>
  801f17:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f1f:	eb 36                	jmp    801f57 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f21:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f2c:	e8 03 f2 ff ff       	call   801134 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f31:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3f:	e8 f0 f1 ff ff       	call   801134 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f52:	e8 dd f1 ff ff       	call   801134 <sys_page_unmap>
    err:
	return r;
}
  801f57:	89 d8                	mov    %ebx,%eax
  801f59:	83 c4 3c             	add    $0x3c,%esp
  801f5c:	5b                   	pop    %ebx
  801f5d:	5e                   	pop    %esi
  801f5e:	5f                   	pop    %edi
  801f5f:	5d                   	pop    %ebp
  801f60:	c3                   	ret    

00801f61 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f71:	89 04 24             	mov    %eax,(%esp)
  801f74:	e8 c1 f4 ff ff       	call   80143a <fd_lookup>
  801f79:	85 c0                	test   %eax,%eax
  801f7b:	78 15                	js     801f92 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f80:	89 04 24             	mov    %eax,(%esp)
  801f83:	e8 44 f4 ff ff       	call   8013cc <fd2data>
	return _pipeisclosed(fd, p);
  801f88:	89 c2                	mov    %eax,%edx
  801f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8d:	e8 15 fd ff ff       	call   801ca7 <_pipeisclosed>
}
  801f92:	c9                   	leave  
  801f93:	c3                   	ret    

00801f94 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f94:	55                   	push   %ebp
  801f95:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f97:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9c:	5d                   	pop    %ebp
  801f9d:	c3                   	ret    

00801f9e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f9e:	55                   	push   %ebp
  801f9f:	89 e5                	mov    %esp,%ebp
  801fa1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fa4:	c7 44 24 04 b8 2a 80 	movl   $0x802ab8,0x4(%esp)
  801fab:	00 
  801fac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801faf:	89 04 24             	mov    %eax,(%esp)
  801fb2:	e8 e4 ec ff ff       	call   800c9b <strcpy>
	return 0;
}
  801fb7:	b8 00 00 00 00       	mov    $0x0,%eax
  801fbc:	c9                   	leave  
  801fbd:	c3                   	ret    

00801fbe <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fca:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fcf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fd5:	eb 30                	jmp    802007 <devcons_write+0x49>
		m = n - tot;
  801fd7:	8b 75 10             	mov    0x10(%ebp),%esi
  801fda:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801fdc:	83 fe 7f             	cmp    $0x7f,%esi
  801fdf:	76 05                	jbe    801fe6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801fe1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fe6:	89 74 24 08          	mov    %esi,0x8(%esp)
  801fea:	03 45 0c             	add    0xc(%ebp),%eax
  801fed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff1:	89 3c 24             	mov    %edi,(%esp)
  801ff4:	e8 1b ee ff ff       	call   800e14 <memmove>
		sys_cputs(buf, m);
  801ff9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ffd:	89 3c 24             	mov    %edi,(%esp)
  802000:	e8 bb ef ff ff       	call   800fc0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802005:	01 f3                	add    %esi,%ebx
  802007:	89 d8                	mov    %ebx,%eax
  802009:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80200c:	72 c9                	jb     801fd7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80200e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802014:	5b                   	pop    %ebx
  802015:	5e                   	pop    %esi
  802016:	5f                   	pop    %edi
  802017:	5d                   	pop    %ebp
  802018:	c3                   	ret    

00802019 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802019:	55                   	push   %ebp
  80201a:	89 e5                	mov    %esp,%ebp
  80201c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80201f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802023:	75 07                	jne    80202c <devcons_read+0x13>
  802025:	eb 25                	jmp    80204c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802027:	e8 42 f0 ff ff       	call   80106e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80202c:	e8 ad ef ff ff       	call   800fde <sys_cgetc>
  802031:	85 c0                	test   %eax,%eax
  802033:	74 f2                	je     802027 <devcons_read+0xe>
  802035:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802037:	85 c0                	test   %eax,%eax
  802039:	78 1d                	js     802058 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80203b:	83 f8 04             	cmp    $0x4,%eax
  80203e:	74 13                	je     802053 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802040:	8b 45 0c             	mov    0xc(%ebp),%eax
  802043:	88 10                	mov    %dl,(%eax)
	return 1;
  802045:	b8 01 00 00 00       	mov    $0x1,%eax
  80204a:	eb 0c                	jmp    802058 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80204c:	b8 00 00 00 00       	mov    $0x0,%eax
  802051:	eb 05                	jmp    802058 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802053:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802058:	c9                   	leave  
  802059:	c3                   	ret    

0080205a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802060:	8b 45 08             	mov    0x8(%ebp),%eax
  802063:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802066:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80206d:	00 
  80206e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802071:	89 04 24             	mov    %eax,(%esp)
  802074:	e8 47 ef ff ff       	call   800fc0 <sys_cputs>
}
  802079:	c9                   	leave  
  80207a:	c3                   	ret    

0080207b <getchar>:

int
getchar(void)
{
  80207b:	55                   	push   %ebp
  80207c:	89 e5                	mov    %esp,%ebp
  80207e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802081:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802088:	00 
  802089:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80208c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802090:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802097:	e8 3a f6 ff ff       	call   8016d6 <read>
	if (r < 0)
  80209c:	85 c0                	test   %eax,%eax
  80209e:	78 0f                	js     8020af <getchar+0x34>
		return r;
	if (r < 1)
  8020a0:	85 c0                	test   %eax,%eax
  8020a2:	7e 06                	jle    8020aa <getchar+0x2f>
		return -E_EOF;
	return c;
  8020a4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020a8:	eb 05                	jmp    8020af <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020aa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020af:	c9                   	leave  
  8020b0:	c3                   	ret    

008020b1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020b1:	55                   	push   %ebp
  8020b2:	89 e5                	mov    %esp,%ebp
  8020b4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020be:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c1:	89 04 24             	mov    %eax,(%esp)
  8020c4:	e8 71 f3 ff ff       	call   80143a <fd_lookup>
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	78 11                	js     8020de <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020d6:	39 10                	cmp    %edx,(%eax)
  8020d8:	0f 94 c0             	sete   %al
  8020db:	0f b6 c0             	movzbl %al,%eax
}
  8020de:	c9                   	leave  
  8020df:	c3                   	ret    

008020e0 <opencons>:

int
opencons(void)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e9:	89 04 24             	mov    %eax,(%esp)
  8020ec:	e8 f6 f2 ff ff       	call   8013e7 <fd_alloc>
  8020f1:	85 c0                	test   %eax,%eax
  8020f3:	78 3c                	js     802131 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020f5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020fc:	00 
  8020fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802100:	89 44 24 04          	mov    %eax,0x4(%esp)
  802104:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80210b:	e8 7d ef ff ff       	call   80108d <sys_page_alloc>
  802110:	85 c0                	test   %eax,%eax
  802112:	78 1d                	js     802131 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802114:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80211a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80211f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802122:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802129:	89 04 24             	mov    %eax,(%esp)
  80212c:	e8 8b f2 ff ff       	call   8013bc <fd2num>
}
  802131:	c9                   	leave  
  802132:	c3                   	ret    
	...

00802134 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	56                   	push   %esi
  802138:	53                   	push   %ebx
  802139:	83 ec 10             	sub    $0x10,%esp
  80213c:	8b 75 08             	mov    0x8(%ebp),%esi
  80213f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802142:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  802145:	85 c0                	test   %eax,%eax
  802147:	75 05                	jne    80214e <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  802149:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  80214e:	89 04 24             	mov    %eax,(%esp)
  802151:	e8 4d f1 ff ff       	call   8012a3 <sys_ipc_recv>
	if (!err) {
  802156:	85 c0                	test   %eax,%eax
  802158:	75 26                	jne    802180 <ipc_recv+0x4c>
		if (from_env_store) {
  80215a:	85 f6                	test   %esi,%esi
  80215c:	74 0a                	je     802168 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  80215e:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802163:	8b 40 74             	mov    0x74(%eax),%eax
  802166:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  802168:	85 db                	test   %ebx,%ebx
  80216a:	74 0a                	je     802176 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  80216c:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802171:	8b 40 78             	mov    0x78(%eax),%eax
  802174:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  802176:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80217b:	8b 40 70             	mov    0x70(%eax),%eax
  80217e:	eb 14                	jmp    802194 <ipc_recv+0x60>
	}
	if (from_env_store) {
  802180:	85 f6                	test   %esi,%esi
  802182:	74 06                	je     80218a <ipc_recv+0x56>
		*from_env_store = 0;
  802184:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  80218a:	85 db                	test   %ebx,%ebx
  80218c:	74 06                	je     802194 <ipc_recv+0x60>
		*perm_store = 0;
  80218e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  802194:	83 c4 10             	add    $0x10,%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5d                   	pop    %ebp
  80219a:	c3                   	ret    

0080219b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80219b:	55                   	push   %ebp
  80219c:	89 e5                	mov    %esp,%ebp
  80219e:	57                   	push   %edi
  80219f:	56                   	push   %esi
  8021a0:	53                   	push   %ebx
  8021a1:	83 ec 1c             	sub    $0x1c,%esp
  8021a4:	8b 75 10             	mov    0x10(%ebp),%esi
  8021a7:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  8021aa:	85 f6                	test   %esi,%esi
  8021ac:	75 05                	jne    8021b3 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  8021ae:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  8021b3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021b7:	89 74 24 08          	mov    %esi,0x8(%esp)
  8021bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c5:	89 04 24             	mov    %eax,(%esp)
  8021c8:	e8 b3 f0 ff ff       	call   801280 <sys_ipc_try_send>
  8021cd:	89 c3                	mov    %eax,%ebx
		sys_yield();
  8021cf:	e8 9a ee ff ff       	call   80106e <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  8021d4:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8021d7:	74 da                	je     8021b3 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  8021d9:	85 db                	test   %ebx,%ebx
  8021db:	74 20                	je     8021fd <ipc_send+0x62>
		panic("send fail: %e", err);
  8021dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8021e1:	c7 44 24 08 c4 2a 80 	movl   $0x802ac4,0x8(%esp)
  8021e8:	00 
  8021e9:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8021f0:	00 
  8021f1:	c7 04 24 d2 2a 80 00 	movl   $0x802ad2,(%esp)
  8021f8:	e8 db e3 ff ff       	call   8005d8 <_panic>
	}
	return;
}
  8021fd:	83 c4 1c             	add    $0x1c,%esp
  802200:	5b                   	pop    %ebx
  802201:	5e                   	pop    %esi
  802202:	5f                   	pop    %edi
  802203:	5d                   	pop    %ebp
  802204:	c3                   	ret    

00802205 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802205:	55                   	push   %ebp
  802206:	89 e5                	mov    %esp,%ebp
  802208:	53                   	push   %ebx
  802209:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80220c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802211:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802218:	89 c2                	mov    %eax,%edx
  80221a:	c1 e2 07             	shl    $0x7,%edx
  80221d:	29 ca                	sub    %ecx,%edx
  80221f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802225:	8b 52 50             	mov    0x50(%edx),%edx
  802228:	39 da                	cmp    %ebx,%edx
  80222a:	75 0f                	jne    80223b <ipc_find_env+0x36>
			return envs[i].env_id;
  80222c:	c1 e0 07             	shl    $0x7,%eax
  80222f:	29 c8                	sub    %ecx,%eax
  802231:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802236:	8b 40 40             	mov    0x40(%eax),%eax
  802239:	eb 0c                	jmp    802247 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80223b:	40                   	inc    %eax
  80223c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802241:	75 ce                	jne    802211 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802243:	66 b8 00 00          	mov    $0x0,%ax
}
  802247:	5b                   	pop    %ebx
  802248:	5d                   	pop    %ebp
  802249:	c3                   	ret    
	...

0080224c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80224c:	55                   	push   %ebp
  80224d:	89 e5                	mov    %esp,%ebp
  80224f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802252:	89 c2                	mov    %eax,%edx
  802254:	c1 ea 16             	shr    $0x16,%edx
  802257:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80225e:	f6 c2 01             	test   $0x1,%dl
  802261:	74 1e                	je     802281 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802263:	c1 e8 0c             	shr    $0xc,%eax
  802266:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80226d:	a8 01                	test   $0x1,%al
  80226f:	74 17                	je     802288 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802271:	c1 e8 0c             	shr    $0xc,%eax
  802274:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80227b:	ef 
  80227c:	0f b7 c0             	movzwl %ax,%eax
  80227f:	eb 0c                	jmp    80228d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802281:	b8 00 00 00 00       	mov    $0x0,%eax
  802286:	eb 05                	jmp    80228d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802288:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80228d:	5d                   	pop    %ebp
  80228e:	c3                   	ret    
	...

00802290 <__udivdi3>:
  802290:	55                   	push   %ebp
  802291:	57                   	push   %edi
  802292:	56                   	push   %esi
  802293:	83 ec 10             	sub    $0x10,%esp
  802296:	8b 74 24 20          	mov    0x20(%esp),%esi
  80229a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80229e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8022a6:	89 cd                	mov    %ecx,%ebp
  8022a8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8022ac:	85 c0                	test   %eax,%eax
  8022ae:	75 2c                	jne    8022dc <__udivdi3+0x4c>
  8022b0:	39 f9                	cmp    %edi,%ecx
  8022b2:	77 68                	ja     80231c <__udivdi3+0x8c>
  8022b4:	85 c9                	test   %ecx,%ecx
  8022b6:	75 0b                	jne    8022c3 <__udivdi3+0x33>
  8022b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8022bd:	31 d2                	xor    %edx,%edx
  8022bf:	f7 f1                	div    %ecx
  8022c1:	89 c1                	mov    %eax,%ecx
  8022c3:	31 d2                	xor    %edx,%edx
  8022c5:	89 f8                	mov    %edi,%eax
  8022c7:	f7 f1                	div    %ecx
  8022c9:	89 c7                	mov    %eax,%edi
  8022cb:	89 f0                	mov    %esi,%eax
  8022cd:	f7 f1                	div    %ecx
  8022cf:	89 c6                	mov    %eax,%esi
  8022d1:	89 f0                	mov    %esi,%eax
  8022d3:	89 fa                	mov    %edi,%edx
  8022d5:	83 c4 10             	add    $0x10,%esp
  8022d8:	5e                   	pop    %esi
  8022d9:	5f                   	pop    %edi
  8022da:	5d                   	pop    %ebp
  8022db:	c3                   	ret    
  8022dc:	39 f8                	cmp    %edi,%eax
  8022de:	77 2c                	ja     80230c <__udivdi3+0x7c>
  8022e0:	0f bd f0             	bsr    %eax,%esi
  8022e3:	83 f6 1f             	xor    $0x1f,%esi
  8022e6:	75 4c                	jne    802334 <__udivdi3+0xa4>
  8022e8:	39 f8                	cmp    %edi,%eax
  8022ea:	bf 00 00 00 00       	mov    $0x0,%edi
  8022ef:	72 0a                	jb     8022fb <__udivdi3+0x6b>
  8022f1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022f5:	0f 87 ad 00 00 00    	ja     8023a8 <__udivdi3+0x118>
  8022fb:	be 01 00 00 00       	mov    $0x1,%esi
  802300:	89 f0                	mov    %esi,%eax
  802302:	89 fa                	mov    %edi,%edx
  802304:	83 c4 10             	add    $0x10,%esp
  802307:	5e                   	pop    %esi
  802308:	5f                   	pop    %edi
  802309:	5d                   	pop    %ebp
  80230a:	c3                   	ret    
  80230b:	90                   	nop
  80230c:	31 ff                	xor    %edi,%edi
  80230e:	31 f6                	xor    %esi,%esi
  802310:	89 f0                	mov    %esi,%eax
  802312:	89 fa                	mov    %edi,%edx
  802314:	83 c4 10             	add    $0x10,%esp
  802317:	5e                   	pop    %esi
  802318:	5f                   	pop    %edi
  802319:	5d                   	pop    %ebp
  80231a:	c3                   	ret    
  80231b:	90                   	nop
  80231c:	89 fa                	mov    %edi,%edx
  80231e:	89 f0                	mov    %esi,%eax
  802320:	f7 f1                	div    %ecx
  802322:	89 c6                	mov    %eax,%esi
  802324:	31 ff                	xor    %edi,%edi
  802326:	89 f0                	mov    %esi,%eax
  802328:	89 fa                	mov    %edi,%edx
  80232a:	83 c4 10             	add    $0x10,%esp
  80232d:	5e                   	pop    %esi
  80232e:	5f                   	pop    %edi
  80232f:	5d                   	pop    %ebp
  802330:	c3                   	ret    
  802331:	8d 76 00             	lea    0x0(%esi),%esi
  802334:	89 f1                	mov    %esi,%ecx
  802336:	d3 e0                	shl    %cl,%eax
  802338:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80233c:	b8 20 00 00 00       	mov    $0x20,%eax
  802341:	29 f0                	sub    %esi,%eax
  802343:	89 ea                	mov    %ebp,%edx
  802345:	88 c1                	mov    %al,%cl
  802347:	d3 ea                	shr    %cl,%edx
  802349:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80234d:	09 ca                	or     %ecx,%edx
  80234f:	89 54 24 08          	mov    %edx,0x8(%esp)
  802353:	89 f1                	mov    %esi,%ecx
  802355:	d3 e5                	shl    %cl,%ebp
  802357:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80235b:	89 fd                	mov    %edi,%ebp
  80235d:	88 c1                	mov    %al,%cl
  80235f:	d3 ed                	shr    %cl,%ebp
  802361:	89 fa                	mov    %edi,%edx
  802363:	89 f1                	mov    %esi,%ecx
  802365:	d3 e2                	shl    %cl,%edx
  802367:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80236b:	88 c1                	mov    %al,%cl
  80236d:	d3 ef                	shr    %cl,%edi
  80236f:	09 d7                	or     %edx,%edi
  802371:	89 f8                	mov    %edi,%eax
  802373:	89 ea                	mov    %ebp,%edx
  802375:	f7 74 24 08          	divl   0x8(%esp)
  802379:	89 d1                	mov    %edx,%ecx
  80237b:	89 c7                	mov    %eax,%edi
  80237d:	f7 64 24 0c          	mull   0xc(%esp)
  802381:	39 d1                	cmp    %edx,%ecx
  802383:	72 17                	jb     80239c <__udivdi3+0x10c>
  802385:	74 09                	je     802390 <__udivdi3+0x100>
  802387:	89 fe                	mov    %edi,%esi
  802389:	31 ff                	xor    %edi,%edi
  80238b:	e9 41 ff ff ff       	jmp    8022d1 <__udivdi3+0x41>
  802390:	8b 54 24 04          	mov    0x4(%esp),%edx
  802394:	89 f1                	mov    %esi,%ecx
  802396:	d3 e2                	shl    %cl,%edx
  802398:	39 c2                	cmp    %eax,%edx
  80239a:	73 eb                	jae    802387 <__udivdi3+0xf7>
  80239c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80239f:	31 ff                	xor    %edi,%edi
  8023a1:	e9 2b ff ff ff       	jmp    8022d1 <__udivdi3+0x41>
  8023a6:	66 90                	xchg   %ax,%ax
  8023a8:	31 f6                	xor    %esi,%esi
  8023aa:	e9 22 ff ff ff       	jmp    8022d1 <__udivdi3+0x41>
	...

008023b0 <__umoddi3>:
  8023b0:	55                   	push   %ebp
  8023b1:	57                   	push   %edi
  8023b2:	56                   	push   %esi
  8023b3:	83 ec 20             	sub    $0x20,%esp
  8023b6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8023ba:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8023be:	89 44 24 14          	mov    %eax,0x14(%esp)
  8023c2:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023c6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023ca:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8023ce:	89 c7                	mov    %eax,%edi
  8023d0:	89 f2                	mov    %esi,%edx
  8023d2:	85 ed                	test   %ebp,%ebp
  8023d4:	75 16                	jne    8023ec <__umoddi3+0x3c>
  8023d6:	39 f1                	cmp    %esi,%ecx
  8023d8:	0f 86 a6 00 00 00    	jbe    802484 <__umoddi3+0xd4>
  8023de:	f7 f1                	div    %ecx
  8023e0:	89 d0                	mov    %edx,%eax
  8023e2:	31 d2                	xor    %edx,%edx
  8023e4:	83 c4 20             	add    $0x20,%esp
  8023e7:	5e                   	pop    %esi
  8023e8:	5f                   	pop    %edi
  8023e9:	5d                   	pop    %ebp
  8023ea:	c3                   	ret    
  8023eb:	90                   	nop
  8023ec:	39 f5                	cmp    %esi,%ebp
  8023ee:	0f 87 ac 00 00 00    	ja     8024a0 <__umoddi3+0xf0>
  8023f4:	0f bd c5             	bsr    %ebp,%eax
  8023f7:	83 f0 1f             	xor    $0x1f,%eax
  8023fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023fe:	0f 84 a8 00 00 00    	je     8024ac <__umoddi3+0xfc>
  802404:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802408:	d3 e5                	shl    %cl,%ebp
  80240a:	bf 20 00 00 00       	mov    $0x20,%edi
  80240f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802413:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802417:	89 f9                	mov    %edi,%ecx
  802419:	d3 e8                	shr    %cl,%eax
  80241b:	09 e8                	or     %ebp,%eax
  80241d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802421:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802425:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802429:	d3 e0                	shl    %cl,%eax
  80242b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80242f:	89 f2                	mov    %esi,%edx
  802431:	d3 e2                	shl    %cl,%edx
  802433:	8b 44 24 14          	mov    0x14(%esp),%eax
  802437:	d3 e0                	shl    %cl,%eax
  802439:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80243d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802441:	89 f9                	mov    %edi,%ecx
  802443:	d3 e8                	shr    %cl,%eax
  802445:	09 d0                	or     %edx,%eax
  802447:	d3 ee                	shr    %cl,%esi
  802449:	89 f2                	mov    %esi,%edx
  80244b:	f7 74 24 18          	divl   0x18(%esp)
  80244f:	89 d6                	mov    %edx,%esi
  802451:	f7 64 24 0c          	mull   0xc(%esp)
  802455:	89 c5                	mov    %eax,%ebp
  802457:	89 d1                	mov    %edx,%ecx
  802459:	39 d6                	cmp    %edx,%esi
  80245b:	72 67                	jb     8024c4 <__umoddi3+0x114>
  80245d:	74 75                	je     8024d4 <__umoddi3+0x124>
  80245f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802463:	29 e8                	sub    %ebp,%eax
  802465:	19 ce                	sbb    %ecx,%esi
  802467:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80246b:	d3 e8                	shr    %cl,%eax
  80246d:	89 f2                	mov    %esi,%edx
  80246f:	89 f9                	mov    %edi,%ecx
  802471:	d3 e2                	shl    %cl,%edx
  802473:	09 d0                	or     %edx,%eax
  802475:	89 f2                	mov    %esi,%edx
  802477:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80247b:	d3 ea                	shr    %cl,%edx
  80247d:	83 c4 20             	add    $0x20,%esp
  802480:	5e                   	pop    %esi
  802481:	5f                   	pop    %edi
  802482:	5d                   	pop    %ebp
  802483:	c3                   	ret    
  802484:	85 c9                	test   %ecx,%ecx
  802486:	75 0b                	jne    802493 <__umoddi3+0xe3>
  802488:	b8 01 00 00 00       	mov    $0x1,%eax
  80248d:	31 d2                	xor    %edx,%edx
  80248f:	f7 f1                	div    %ecx
  802491:	89 c1                	mov    %eax,%ecx
  802493:	89 f0                	mov    %esi,%eax
  802495:	31 d2                	xor    %edx,%edx
  802497:	f7 f1                	div    %ecx
  802499:	89 f8                	mov    %edi,%eax
  80249b:	e9 3e ff ff ff       	jmp    8023de <__umoddi3+0x2e>
  8024a0:	89 f2                	mov    %esi,%edx
  8024a2:	83 c4 20             	add    $0x20,%esp
  8024a5:	5e                   	pop    %esi
  8024a6:	5f                   	pop    %edi
  8024a7:	5d                   	pop    %ebp
  8024a8:	c3                   	ret    
  8024a9:	8d 76 00             	lea    0x0(%esi),%esi
  8024ac:	39 f5                	cmp    %esi,%ebp
  8024ae:	72 04                	jb     8024b4 <__umoddi3+0x104>
  8024b0:	39 f9                	cmp    %edi,%ecx
  8024b2:	77 06                	ja     8024ba <__umoddi3+0x10a>
  8024b4:	89 f2                	mov    %esi,%edx
  8024b6:	29 cf                	sub    %ecx,%edi
  8024b8:	19 ea                	sbb    %ebp,%edx
  8024ba:	89 f8                	mov    %edi,%eax
  8024bc:	83 c4 20             	add    $0x20,%esp
  8024bf:	5e                   	pop    %esi
  8024c0:	5f                   	pop    %edi
  8024c1:	5d                   	pop    %ebp
  8024c2:	c3                   	ret    
  8024c3:	90                   	nop
  8024c4:	89 d1                	mov    %edx,%ecx
  8024c6:	89 c5                	mov    %eax,%ebp
  8024c8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8024cc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8024d0:	eb 8d                	jmp    80245f <__umoddi3+0xaf>
  8024d2:	66 90                	xchg   %ax,%ax
  8024d4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8024d8:	72 ea                	jb     8024c4 <__umoddi3+0x114>
  8024da:	89 f1                	mov    %esi,%ecx
  8024dc:	eb 81                	jmp    80245f <__umoddi3+0xaf>

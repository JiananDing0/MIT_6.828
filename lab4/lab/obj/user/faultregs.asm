
obj/user/faultregs:     file format elf32-i386


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
  80004c:	c7 44 24 04 f1 15 80 	movl   $0x8015f1,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 c0 15 80 00 	movl   $0x8015c0,(%esp)
  80005b:	e8 68 06 00 00       	call   8006c8 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 06                	mov    (%esi),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 03                	mov    (%ebx),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 d0 15 80 	movl   $0x8015d0,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 d4 15 80 00 	movl   $0x8015d4,(%esp)
  80007b:	e8 48 06 00 00       	call   8006c8 <cprintf>
  800080:	8b 06                	mov    (%esi),%eax
  800082:	39 03                	cmp    %eax,(%ebx)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 e4 15 80 00 	movl   $0x8015e4,(%esp)
  80008d:	e8 36 06 00 00       	call   8006c8 <cprintf>

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
  800099:	c7 04 24 e8 15 80 00 	movl   $0x8015e8,(%esp)
  8000a0:	e8 23 06 00 00       	call   8006c8 <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 46 04             	mov    0x4(%esi),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 f2 15 80 	movl   $0x8015f2,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 d4 15 80 00 	movl   $0x8015d4,(%esp)
  8000c7:	e8 fc 05 00 00       	call   8006c8 <cprintf>
  8000cc:	8b 46 04             	mov    0x4(%esi),%eax
  8000cf:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 e4 15 80 00 	movl   $0x8015e4,(%esp)
  8000db:	e8 e8 05 00 00       	call   8006c8 <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 e8 15 80 00 	movl   $0x8015e8,(%esp)
  8000e9:	e8 da 05 00 00       	call   8006c8 <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 46 08             	mov    0x8(%esi),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 f6 15 80 	movl   $0x8015f6,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 d4 15 80 00 	movl   $0x8015d4,(%esp)
  800110:	e8 b3 05 00 00       	call   8006c8 <cprintf>
  800115:	8b 46 08             	mov    0x8(%esi),%eax
  800118:	39 43 08             	cmp    %eax,0x8(%ebx)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 e4 15 80 00 	movl   $0x8015e4,(%esp)
  800124:	e8 9f 05 00 00       	call   8006c8 <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 e8 15 80 00 	movl   $0x8015e8,(%esp)
  800132:	e8 91 05 00 00       	call   8006c8 <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 46 10             	mov    0x10(%esi),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 43 10             	mov    0x10(%ebx),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 fa 15 80 	movl   $0x8015fa,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 d4 15 80 00 	movl   $0x8015d4,(%esp)
  800159:	e8 6a 05 00 00       	call   8006c8 <cprintf>
  80015e:	8b 46 10             	mov    0x10(%esi),%eax
  800161:	39 43 10             	cmp    %eax,0x10(%ebx)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 e4 15 80 00 	movl   $0x8015e4,(%esp)
  80016d:	e8 56 05 00 00       	call   8006c8 <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 e8 15 80 00 	movl   $0x8015e8,(%esp)
  80017b:	e8 48 05 00 00       	call   8006c8 <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 46 14             	mov    0x14(%esi),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 43 14             	mov    0x14(%ebx),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 fe 15 80 	movl   $0x8015fe,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 d4 15 80 00 	movl   $0x8015d4,(%esp)
  8001a2:	e8 21 05 00 00       	call   8006c8 <cprintf>
  8001a7:	8b 46 14             	mov    0x14(%esi),%eax
  8001aa:	39 43 14             	cmp    %eax,0x14(%ebx)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 e4 15 80 00 	movl   $0x8015e4,(%esp)
  8001b6:	e8 0d 05 00 00       	call   8006c8 <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 e8 15 80 00 	movl   $0x8015e8,(%esp)
  8001c4:	e8 ff 04 00 00       	call   8006c8 <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 46 18             	mov    0x18(%esi),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 02 16 80 	movl   $0x801602,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 d4 15 80 00 	movl   $0x8015d4,(%esp)
  8001eb:	e8 d8 04 00 00       	call   8006c8 <cprintf>
  8001f0:	8b 46 18             	mov    0x18(%esi),%eax
  8001f3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 e4 15 80 00 	movl   $0x8015e4,(%esp)
  8001ff:	e8 c4 04 00 00       	call   8006c8 <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 e8 15 80 00 	movl   $0x8015e8,(%esp)
  80020d:	e8 b6 04 00 00       	call   8006c8 <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 06 16 80 	movl   $0x801606,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 d4 15 80 00 	movl   $0x8015d4,(%esp)
  800234:	e8 8f 04 00 00       	call   8006c8 <cprintf>
  800239:	8b 46 1c             	mov    0x1c(%esi),%eax
  80023c:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 e4 15 80 00 	movl   $0x8015e4,(%esp)
  800248:	e8 7b 04 00 00       	call   8006c8 <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 e8 15 80 00 	movl   $0x8015e8,(%esp)
  800256:	e8 6d 04 00 00       	call   8006c8 <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 46 20             	mov    0x20(%esi),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 43 20             	mov    0x20(%ebx),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 0a 16 80 	movl   $0x80160a,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 d4 15 80 00 	movl   $0x8015d4,(%esp)
  80027d:	e8 46 04 00 00       	call   8006c8 <cprintf>
  800282:	8b 46 20             	mov    0x20(%esi),%eax
  800285:	39 43 20             	cmp    %eax,0x20(%ebx)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 e4 15 80 00 	movl   $0x8015e4,(%esp)
  800291:	e8 32 04 00 00       	call   8006c8 <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 e8 15 80 00 	movl   $0x8015e8,(%esp)
  80029f:	e8 24 04 00 00       	call   8006c8 <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 46 24             	mov    0x24(%esi),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 43 24             	mov    0x24(%ebx),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 0e 16 80 	movl   $0x80160e,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 d4 15 80 00 	movl   $0x8015d4,(%esp)
  8002c6:	e8 fd 03 00 00       	call   8006c8 <cprintf>
  8002cb:	8b 46 24             	mov    0x24(%esi),%eax
  8002ce:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 e4 15 80 00 	movl   $0x8015e4,(%esp)
  8002da:	e8 e9 03 00 00       	call   8006c8 <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 e8 15 80 00 	movl   $0x8015e8,(%esp)
  8002e8:	e8 db 03 00 00       	call   8006c8 <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 46 28             	mov    0x28(%esi),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 43 28             	mov    0x28(%ebx),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 15 16 80 	movl   $0x801615,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 d4 15 80 00 	movl   $0x8015d4,(%esp)
  80030f:	e8 b4 03 00 00       	call   8006c8 <cprintf>
  800314:	8b 46 28             	mov    0x28(%esi),%eax
  800317:	39 43 28             	cmp    %eax,0x28(%ebx)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 e4 15 80 00 	movl   $0x8015e4,(%esp)
  800323:	e8 a0 03 00 00       	call   8006c8 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 19 16 80 00 	movl   $0x801619,(%esp)
  800336:	e8 8d 03 00 00       	call   8006c8 <cprintf>
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
  800341:	c7 04 24 e8 15 80 00 	movl   $0x8015e8,(%esp)
  800348:	e8 7b 03 00 00       	call   8006c8 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 19 16 80 00 	movl   $0x801619,(%esp)
  80035b:	e8 68 03 00 00       	call   8006c8 <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 e4 15 80 00 	movl   $0x8015e4,(%esp)
  800369:	e8 5a 03 00 00       	call   8006c8 <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 e8 15 80 00 	movl   $0x8015e8,(%esp)
  800377:	e8 4c 03 00 00       	call   8006c8 <cprintf>
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
  8003a4:	c7 44 24 08 80 16 80 	movl   $0x801680,0x8(%esp)
  8003ab:	00 
  8003ac:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b3:	00 
  8003b4:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  8003bb:	e8 10 02 00 00       	call   8005d0 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003c0:	bf a0 20 80 00       	mov    $0x8020a0,%edi
  8003c5:	8d 70 08             	lea    0x8(%eax),%esi
  8003c8:	b9 08 00 00 00       	mov    $0x8,%ecx
  8003cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	during.eip = utf->utf_eip;
  8003cf:	8b 50 28             	mov    0x28(%eax),%edx
  8003d2:	89 17                	mov    %edx,(%edi)
	during.eflags = utf->utf_eflags & ~FL_RF;
  8003d4:	8b 50 2c             	mov    0x2c(%eax),%edx
  8003d7:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  8003dd:	89 15 c4 20 80 00    	mov    %edx,0x8020c4
	during.esp = utf->utf_esp;
  8003e3:	8b 40 30             	mov    0x30(%eax),%eax
  8003e6:	a3 c8 20 80 00       	mov    %eax,0x8020c8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  8003eb:	c7 44 24 04 3f 16 80 	movl   $0x80163f,0x4(%esp)
  8003f2:	00 
  8003f3:	c7 04 24 4d 16 80 00 	movl   $0x80164d,(%esp)
  8003fa:	b9 a0 20 80 00       	mov    $0x8020a0,%ecx
  8003ff:	ba 38 16 80 00       	mov    $0x801638,%edx
  800404:	b8 20 20 80 00       	mov    $0x802020,%eax
  800409:	e8 26 fc ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80040e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800415:	00 
  800416:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80041d:	00 
  80041e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800425:	e8 5b 0c 00 00       	call   801085 <sys_page_alloc>
  80042a:	85 c0                	test   %eax,%eax
  80042c:	79 20                	jns    80044e <pgfault+0xca>
		panic("sys_page_alloc: %e", r);
  80042e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800432:	c7 44 24 08 54 16 80 	movl   $0x801654,0x8(%esp)
  800439:	00 
  80043a:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800441:	00 
  800442:	c7 04 24 27 16 80 00 	movl   $0x801627,(%esp)
  800449:	e8 82 01 00 00       	call   8005d0 <_panic>
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
  800462:	e8 35 0e 00 00       	call   80129c <set_pgfault_handler>

	asm volatile(
  800467:	50                   	push   %eax
  800468:	9c                   	pushf  
  800469:	58                   	pop    %eax
  80046a:	0d d5 08 00 00       	or     $0x8d5,%eax
  80046f:	50                   	push   %eax
  800470:	9d                   	popf   
  800471:	a3 44 20 80 00       	mov    %eax,0x802044
  800476:	8d 05 b1 04 80 00    	lea    0x8004b1,%eax
  80047c:	a3 40 20 80 00       	mov    %eax,0x802040
  800481:	58                   	pop    %eax
  800482:	89 3d 20 20 80 00    	mov    %edi,0x802020
  800488:	89 35 24 20 80 00    	mov    %esi,0x802024
  80048e:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  800494:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  80049a:	89 15 34 20 80 00    	mov    %edx,0x802034
  8004a0:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  8004a6:	a3 3c 20 80 00       	mov    %eax,0x80203c
  8004ab:	89 25 48 20 80 00    	mov    %esp,0x802048
  8004b1:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004b8:	00 00 00 
  8004bb:	89 3d 60 20 80 00    	mov    %edi,0x802060
  8004c1:	89 35 64 20 80 00    	mov    %esi,0x802064
  8004c7:	89 2d 68 20 80 00    	mov    %ebp,0x802068
  8004cd:	89 1d 70 20 80 00    	mov    %ebx,0x802070
  8004d3:	89 15 74 20 80 00    	mov    %edx,0x802074
  8004d9:	89 0d 78 20 80 00    	mov    %ecx,0x802078
  8004df:	a3 7c 20 80 00       	mov    %eax,0x80207c
  8004e4:	89 25 88 20 80 00    	mov    %esp,0x802088
  8004ea:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  8004f0:	8b 35 24 20 80 00    	mov    0x802024,%esi
  8004f6:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  8004fc:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  800502:	8b 15 34 20 80 00    	mov    0x802034,%edx
  800508:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  80050e:	a1 3c 20 80 00       	mov    0x80203c,%eax
  800513:	8b 25 48 20 80 00    	mov    0x802048,%esp
  800519:	50                   	push   %eax
  80051a:	9c                   	pushf  
  80051b:	58                   	pop    %eax
  80051c:	a3 84 20 80 00       	mov    %eax,0x802084
  800521:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800522:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800529:	74 0c                	je     800537 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80052b:	c7 04 24 b4 16 80 00 	movl   $0x8016b4,(%esp)
  800532:	e8 91 01 00 00       	call   8006c8 <cprintf>
	after.eip = before.eip;
  800537:	a1 40 20 80 00       	mov    0x802040,%eax
  80053c:	a3 80 20 80 00       	mov    %eax,0x802080

	check_regs(&before, "before", &after, "after", "after page-fault");
  800541:	c7 44 24 04 67 16 80 	movl   $0x801667,0x4(%esp)
  800548:	00 
  800549:	c7 04 24 78 16 80 00 	movl   $0x801678,(%esp)
  800550:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800555:	ba 38 16 80 00       	mov    $0x801638,%edx
  80055a:	b8 20 20 80 00       	mov    $0x802020,%eax
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
  800576:	e8 cc 0a 00 00       	call   801047 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80057b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800580:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800587:	c1 e0 07             	shl    $0x7,%eax
  80058a:	29 d0                	sub    %edx,%eax
  80058c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800591:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800596:	85 f6                	test   %esi,%esi
  800598:	7e 07                	jle    8005a1 <libmain+0x39>
		binaryname = argv[0];
  80059a:	8b 03                	mov    (%ebx),%eax
  80059c:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  8005c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005c9:	e8 27 0a 00 00       	call   800ff5 <sys_env_destroy>
}
  8005ce:	c9                   	leave  
  8005cf:	c3                   	ret    

008005d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005d0:	55                   	push   %ebp
  8005d1:	89 e5                	mov    %esp,%ebp
  8005d3:	56                   	push   %esi
  8005d4:	53                   	push   %ebx
  8005d5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005d8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005db:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8005e1:	e8 61 0a 00 00       	call   801047 <sys_getenvid>
  8005e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fc:	c7 04 24 e0 16 80 00 	movl   $0x8016e0,(%esp)
  800603:	e8 c0 00 00 00       	call   8006c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800608:	89 74 24 04          	mov    %esi,0x4(%esp)
  80060c:	8b 45 10             	mov    0x10(%ebp),%eax
  80060f:	89 04 24             	mov    %eax,(%esp)
  800612:	e8 50 00 00 00       	call   800667 <vcprintf>
	cprintf("\n");
  800617:	c7 04 24 f0 15 80 00 	movl   $0x8015f0,(%esp)
  80061e:	e8 a5 00 00 00       	call   8006c8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800623:	cc                   	int3   
  800624:	eb fd                	jmp    800623 <_panic+0x53>
	...

00800628 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	53                   	push   %ebx
  80062c:	83 ec 14             	sub    $0x14,%esp
  80062f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800632:	8b 03                	mov    (%ebx),%eax
  800634:	8b 55 08             	mov    0x8(%ebp),%edx
  800637:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80063b:	40                   	inc    %eax
  80063c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80063e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800643:	75 19                	jne    80065e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800645:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80064c:	00 
  80064d:	8d 43 08             	lea    0x8(%ebx),%eax
  800650:	89 04 24             	mov    %eax,(%esp)
  800653:	e8 60 09 00 00       	call   800fb8 <sys_cputs>
		b->idx = 0;
  800658:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80065e:	ff 43 04             	incl   0x4(%ebx)
}
  800661:	83 c4 14             	add    $0x14,%esp
  800664:	5b                   	pop    %ebx
  800665:	5d                   	pop    %ebp
  800666:	c3                   	ret    

00800667 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800667:	55                   	push   %ebp
  800668:	89 e5                	mov    %esp,%ebp
  80066a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800670:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800677:	00 00 00 
	b.cnt = 0;
  80067a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800681:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800684:	8b 45 0c             	mov    0xc(%ebp),%eax
  800687:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068b:	8b 45 08             	mov    0x8(%ebp),%eax
  80068e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800692:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800698:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069c:	c7 04 24 28 06 80 00 	movl   $0x800628,(%esp)
  8006a3:	e8 82 01 00 00       	call   80082a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006a8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006b8:	89 04 24             	mov    %eax,(%esp)
  8006bb:	e8 f8 08 00 00       	call   800fb8 <sys_cputs>

	return b.cnt;
}
  8006c0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006ce:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d8:	89 04 24             	mov    %eax,(%esp)
  8006db:	e8 87 ff ff ff       	call   800667 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006e0:	c9                   	leave  
  8006e1:	c3                   	ret    
	...

008006e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	57                   	push   %edi
  8006e8:	56                   	push   %esi
  8006e9:	53                   	push   %ebx
  8006ea:	83 ec 3c             	sub    $0x3c,%esp
  8006ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f0:	89 d7                	mov    %edx,%edi
  8006f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006fe:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800701:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800704:	85 c0                	test   %eax,%eax
  800706:	75 08                	jne    800710 <printnum+0x2c>
  800708:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80070b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80070e:	77 57                	ja     800767 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800710:	89 74 24 10          	mov    %esi,0x10(%esp)
  800714:	4b                   	dec    %ebx
  800715:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800719:	8b 45 10             	mov    0x10(%ebp),%eax
  80071c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800720:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800724:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800728:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80072f:	00 
  800730:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800733:	89 04 24             	mov    %eax,(%esp)
  800736:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800739:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073d:	e8 1e 0c 00 00       	call   801360 <__udivdi3>
  800742:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800746:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80074a:	89 04 24             	mov    %eax,(%esp)
  80074d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800751:	89 fa                	mov    %edi,%edx
  800753:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800756:	e8 89 ff ff ff       	call   8006e4 <printnum>
  80075b:	eb 0f                	jmp    80076c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80075d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800761:	89 34 24             	mov    %esi,(%esp)
  800764:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800767:	4b                   	dec    %ebx
  800768:	85 db                	test   %ebx,%ebx
  80076a:	7f f1                	jg     80075d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80076c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800770:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800774:	8b 45 10             	mov    0x10(%ebp),%eax
  800777:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800782:	00 
  800783:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800786:	89 04 24             	mov    %eax,(%esp)
  800789:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80078c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800790:	e8 eb 0c 00 00       	call   801480 <__umoddi3>
  800795:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800799:	0f be 80 03 17 80 00 	movsbl 0x801703(%eax),%eax
  8007a0:	89 04 24             	mov    %eax,(%esp)
  8007a3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8007a6:	83 c4 3c             	add    $0x3c,%esp
  8007a9:	5b                   	pop    %ebx
  8007aa:	5e                   	pop    %esi
  8007ab:	5f                   	pop    %edi
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007b1:	83 fa 01             	cmp    $0x1,%edx
  8007b4:	7e 0e                	jle    8007c4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007b6:	8b 10                	mov    (%eax),%edx
  8007b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007bb:	89 08                	mov    %ecx,(%eax)
  8007bd:	8b 02                	mov    (%edx),%eax
  8007bf:	8b 52 04             	mov    0x4(%edx),%edx
  8007c2:	eb 22                	jmp    8007e6 <getuint+0x38>
	else if (lflag)
  8007c4:	85 d2                	test   %edx,%edx
  8007c6:	74 10                	je     8007d8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007c8:	8b 10                	mov    (%eax),%edx
  8007ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007cd:	89 08                	mov    %ecx,(%eax)
  8007cf:	8b 02                	mov    (%edx),%eax
  8007d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d6:	eb 0e                	jmp    8007e6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007d8:	8b 10                	mov    (%eax),%edx
  8007da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007dd:	89 08                	mov    %ecx,(%eax)
  8007df:	8b 02                	mov    (%edx),%eax
  8007e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007ee:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8007f1:	8b 10                	mov    (%eax),%edx
  8007f3:	3b 50 04             	cmp    0x4(%eax),%edx
  8007f6:	73 08                	jae    800800 <sprintputch+0x18>
		*b->buf++ = ch;
  8007f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fb:	88 0a                	mov    %cl,(%edx)
  8007fd:	42                   	inc    %edx
  8007fe:	89 10                	mov    %edx,(%eax)
}
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800808:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80080b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080f:	8b 45 10             	mov    0x10(%ebp),%eax
  800812:	89 44 24 08          	mov    %eax,0x8(%esp)
  800816:	8b 45 0c             	mov    0xc(%ebp),%eax
  800819:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	89 04 24             	mov    %eax,(%esp)
  800823:	e8 02 00 00 00       	call   80082a <vprintfmt>
	va_end(ap);
}
  800828:	c9                   	leave  
  800829:	c3                   	ret    

0080082a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	57                   	push   %edi
  80082e:	56                   	push   %esi
  80082f:	53                   	push   %ebx
  800830:	83 ec 4c             	sub    $0x4c,%esp
  800833:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800836:	8b 75 10             	mov    0x10(%ebp),%esi
  800839:	eb 12                	jmp    80084d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80083b:	85 c0                	test   %eax,%eax
  80083d:	0f 84 8b 03 00 00    	je     800bce <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800843:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800847:	89 04 24             	mov    %eax,(%esp)
  80084a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80084d:	0f b6 06             	movzbl (%esi),%eax
  800850:	46                   	inc    %esi
  800851:	83 f8 25             	cmp    $0x25,%eax
  800854:	75 e5                	jne    80083b <vprintfmt+0x11>
  800856:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80085a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800861:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800866:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80086d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800872:	eb 26                	jmp    80089a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800874:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800877:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80087b:	eb 1d                	jmp    80089a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800880:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800884:	eb 14                	jmp    80089a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800886:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800889:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800890:	eb 08                	jmp    80089a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800892:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800895:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80089a:	0f b6 06             	movzbl (%esi),%eax
  80089d:	8d 56 01             	lea    0x1(%esi),%edx
  8008a0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8008a3:	8a 16                	mov    (%esi),%dl
  8008a5:	83 ea 23             	sub    $0x23,%edx
  8008a8:	80 fa 55             	cmp    $0x55,%dl
  8008ab:	0f 87 01 03 00 00    	ja     800bb2 <vprintfmt+0x388>
  8008b1:	0f b6 d2             	movzbl %dl,%edx
  8008b4:	ff 24 95 c0 17 80 00 	jmp    *0x8017c0(,%edx,4)
  8008bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008be:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008c3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8008c6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8008ca:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008cd:	8d 50 d0             	lea    -0x30(%eax),%edx
  8008d0:	83 fa 09             	cmp    $0x9,%edx
  8008d3:	77 2a                	ja     8008ff <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008d5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008d6:	eb eb                	jmp    8008c3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008db:	8d 50 04             	lea    0x4(%eax),%edx
  8008de:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008e6:	eb 17                	jmp    8008ff <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8008e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008ec:	78 98                	js     800886 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008f1:	eb a7                	jmp    80089a <vprintfmt+0x70>
  8008f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008f6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8008fd:	eb 9b                	jmp    80089a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8008ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800903:	79 95                	jns    80089a <vprintfmt+0x70>
  800905:	eb 8b                	jmp    800892 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800907:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800908:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80090b:	eb 8d                	jmp    80089a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80090d:	8b 45 14             	mov    0x14(%ebp),%eax
  800910:	8d 50 04             	lea    0x4(%eax),%edx
  800913:	89 55 14             	mov    %edx,0x14(%ebp)
  800916:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091a:	8b 00                	mov    (%eax),%eax
  80091c:	89 04 24             	mov    %eax,(%esp)
  80091f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800922:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800925:	e9 23 ff ff ff       	jmp    80084d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80092a:	8b 45 14             	mov    0x14(%ebp),%eax
  80092d:	8d 50 04             	lea    0x4(%eax),%edx
  800930:	89 55 14             	mov    %edx,0x14(%ebp)
  800933:	8b 00                	mov    (%eax),%eax
  800935:	85 c0                	test   %eax,%eax
  800937:	79 02                	jns    80093b <vprintfmt+0x111>
  800939:	f7 d8                	neg    %eax
  80093b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80093d:	83 f8 08             	cmp    $0x8,%eax
  800940:	7f 0b                	jg     80094d <vprintfmt+0x123>
  800942:	8b 04 85 20 19 80 00 	mov    0x801920(,%eax,4),%eax
  800949:	85 c0                	test   %eax,%eax
  80094b:	75 23                	jne    800970 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80094d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800951:	c7 44 24 08 1b 17 80 	movl   $0x80171b,0x8(%esp)
  800958:	00 
  800959:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	89 04 24             	mov    %eax,(%esp)
  800963:	e8 9a fe ff ff       	call   800802 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800968:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80096b:	e9 dd fe ff ff       	jmp    80084d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800970:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800974:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  80097b:	00 
  80097c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800980:	8b 55 08             	mov    0x8(%ebp),%edx
  800983:	89 14 24             	mov    %edx,(%esp)
  800986:	e8 77 fe ff ff       	call   800802 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80098b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80098e:	e9 ba fe ff ff       	jmp    80084d <vprintfmt+0x23>
  800993:	89 f9                	mov    %edi,%ecx
  800995:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800998:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80099b:	8b 45 14             	mov    0x14(%ebp),%eax
  80099e:	8d 50 04             	lea    0x4(%eax),%edx
  8009a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a4:	8b 30                	mov    (%eax),%esi
  8009a6:	85 f6                	test   %esi,%esi
  8009a8:	75 05                	jne    8009af <vprintfmt+0x185>
				p = "(null)";
  8009aa:	be 14 17 80 00       	mov    $0x801714,%esi
			if (width > 0 && padc != '-')
  8009af:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009b3:	0f 8e 84 00 00 00    	jle    800a3d <vprintfmt+0x213>
  8009b9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8009bd:	74 7e                	je     800a3d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009bf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009c3:	89 34 24             	mov    %esi,(%esp)
  8009c6:	e8 ab 02 00 00       	call   800c76 <strnlen>
  8009cb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009ce:	29 c2                	sub    %eax,%edx
  8009d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8009d3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009d7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8009da:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8009dd:	89 de                	mov    %ebx,%esi
  8009df:	89 d3                	mov    %edx,%ebx
  8009e1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e3:	eb 0b                	jmp    8009f0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8009e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009e9:	89 3c 24             	mov    %edi,(%esp)
  8009ec:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ef:	4b                   	dec    %ebx
  8009f0:	85 db                	test   %ebx,%ebx
  8009f2:	7f f1                	jg     8009e5 <vprintfmt+0x1bb>
  8009f4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8009f7:	89 f3                	mov    %esi,%ebx
  8009f9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8009fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009ff:	85 c0                	test   %eax,%eax
  800a01:	79 05                	jns    800a08 <vprintfmt+0x1de>
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
  800a08:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a0b:	29 c2                	sub    %eax,%edx
  800a0d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a10:	eb 2b                	jmp    800a3d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a12:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a16:	74 18                	je     800a30 <vprintfmt+0x206>
  800a18:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a1b:	83 fa 5e             	cmp    $0x5e,%edx
  800a1e:	76 10                	jbe    800a30 <vprintfmt+0x206>
					putch('?', putdat);
  800a20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a24:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a2b:	ff 55 08             	call   *0x8(%ebp)
  800a2e:	eb 0a                	jmp    800a3a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800a30:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a34:	89 04 24             	mov    %eax,(%esp)
  800a37:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a3a:	ff 4d e4             	decl   -0x1c(%ebp)
  800a3d:	0f be 06             	movsbl (%esi),%eax
  800a40:	46                   	inc    %esi
  800a41:	85 c0                	test   %eax,%eax
  800a43:	74 21                	je     800a66 <vprintfmt+0x23c>
  800a45:	85 ff                	test   %edi,%edi
  800a47:	78 c9                	js     800a12 <vprintfmt+0x1e8>
  800a49:	4f                   	dec    %edi
  800a4a:	79 c6                	jns    800a12 <vprintfmt+0x1e8>
  800a4c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a4f:	89 de                	mov    %ebx,%esi
  800a51:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a54:	eb 18                	jmp    800a6e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a56:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a5a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a61:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a63:	4b                   	dec    %ebx
  800a64:	eb 08                	jmp    800a6e <vprintfmt+0x244>
  800a66:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a69:	89 de                	mov    %ebx,%esi
  800a6b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a6e:	85 db                	test   %ebx,%ebx
  800a70:	7f e4                	jg     800a56 <vprintfmt+0x22c>
  800a72:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a75:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a77:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a7a:	e9 ce fd ff ff       	jmp    80084d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a7f:	83 f9 01             	cmp    $0x1,%ecx
  800a82:	7e 10                	jle    800a94 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800a84:	8b 45 14             	mov    0x14(%ebp),%eax
  800a87:	8d 50 08             	lea    0x8(%eax),%edx
  800a8a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a8d:	8b 30                	mov    (%eax),%esi
  800a8f:	8b 78 04             	mov    0x4(%eax),%edi
  800a92:	eb 26                	jmp    800aba <vprintfmt+0x290>
	else if (lflag)
  800a94:	85 c9                	test   %ecx,%ecx
  800a96:	74 12                	je     800aaa <vprintfmt+0x280>
		return va_arg(*ap, long);
  800a98:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9b:	8d 50 04             	lea    0x4(%eax),%edx
  800a9e:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa1:	8b 30                	mov    (%eax),%esi
  800aa3:	89 f7                	mov    %esi,%edi
  800aa5:	c1 ff 1f             	sar    $0x1f,%edi
  800aa8:	eb 10                	jmp    800aba <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800aaa:	8b 45 14             	mov    0x14(%ebp),%eax
  800aad:	8d 50 04             	lea    0x4(%eax),%edx
  800ab0:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab3:	8b 30                	mov    (%eax),%esi
  800ab5:	89 f7                	mov    %esi,%edi
  800ab7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800aba:	85 ff                	test   %edi,%edi
  800abc:	78 0a                	js     800ac8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800abe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ac3:	e9 ac 00 00 00       	jmp    800b74 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800ac8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800acc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800ad3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ad6:	f7 de                	neg    %esi
  800ad8:	83 d7 00             	adc    $0x0,%edi
  800adb:	f7 df                	neg    %edi
			}
			base = 10;
  800add:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae2:	e9 8d 00 00 00       	jmp    800b74 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ae7:	89 ca                	mov    %ecx,%edx
  800ae9:	8d 45 14             	lea    0x14(%ebp),%eax
  800aec:	e8 bd fc ff ff       	call   8007ae <getuint>
  800af1:	89 c6                	mov    %eax,%esi
  800af3:	89 d7                	mov    %edx,%edi
			base = 10;
  800af5:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800afa:	eb 78                	jmp    800b74 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800afc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b00:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b07:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800b0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b0e:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b15:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800b18:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b1c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800b23:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b26:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800b29:	e9 1f fd ff ff       	jmp    80084d <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800b2e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b32:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b39:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b3c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b40:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b47:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b4a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4d:	8d 50 04             	lea    0x4(%eax),%edx
  800b50:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b53:	8b 30                	mov    (%eax),%esi
  800b55:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b5a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b5f:	eb 13                	jmp    800b74 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b61:	89 ca                	mov    %ecx,%edx
  800b63:	8d 45 14             	lea    0x14(%ebp),%eax
  800b66:	e8 43 fc ff ff       	call   8007ae <getuint>
  800b6b:	89 c6                	mov    %eax,%esi
  800b6d:	89 d7                	mov    %edx,%edi
			base = 16;
  800b6f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b74:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800b78:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b7c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b7f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b83:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b87:	89 34 24             	mov    %esi,(%esp)
  800b8a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b8e:	89 da                	mov    %ebx,%edx
  800b90:	8b 45 08             	mov    0x8(%ebp),%eax
  800b93:	e8 4c fb ff ff       	call   8006e4 <printnum>
			break;
  800b98:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b9b:	e9 ad fc ff ff       	jmp    80084d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ba0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ba4:	89 04 24             	mov    %eax,(%esp)
  800ba7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800baa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800bad:	e9 9b fc ff ff       	jmp    80084d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bb2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bb6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800bbd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bc0:	eb 01                	jmp    800bc3 <vprintfmt+0x399>
  800bc2:	4e                   	dec    %esi
  800bc3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bc7:	75 f9                	jne    800bc2 <vprintfmt+0x398>
  800bc9:	e9 7f fc ff ff       	jmp    80084d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800bce:	83 c4 4c             	add    $0x4c,%esp
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	83 ec 28             	sub    $0x28,%esp
  800bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800be2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800be5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800be9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	74 30                	je     800c27 <vsnprintf+0x51>
  800bf7:	85 d2                	test   %edx,%edx
  800bf9:	7e 33                	jle    800c2e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bfb:	8b 45 14             	mov    0x14(%ebp),%eax
  800bfe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c02:	8b 45 10             	mov    0x10(%ebp),%eax
  800c05:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c09:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c10:	c7 04 24 e8 07 80 00 	movl   $0x8007e8,(%esp)
  800c17:	e8 0e fc ff ff       	call   80082a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c1f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c25:	eb 0c                	jmp    800c33 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c27:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c2c:	eb 05                	jmp    800c33 <vsnprintf+0x5d>
  800c2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c33:	c9                   	leave  
  800c34:	c3                   	ret    

00800c35 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c3b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c42:	8b 45 10             	mov    0x10(%ebp),%eax
  800c45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c50:	8b 45 08             	mov    0x8(%ebp),%eax
  800c53:	89 04 24             	mov    %eax,(%esp)
  800c56:	e8 7b ff ff ff       	call   800bd6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c5b:	c9                   	leave  
  800c5c:	c3                   	ret    
  800c5d:	00 00                	add    %al,(%eax)
	...

00800c60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c66:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6b:	eb 01                	jmp    800c6e <strlen+0xe>
		n++;
  800c6d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c6e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c72:	75 f9                	jne    800c6d <strlen+0xd>
		n++;
	return n;
}
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800c7c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c84:	eb 01                	jmp    800c87 <strnlen+0x11>
		n++;
  800c86:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c87:	39 d0                	cmp    %edx,%eax
  800c89:	74 06                	je     800c91 <strnlen+0x1b>
  800c8b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c8f:	75 f5                	jne    800c86 <strnlen+0x10>
		n++;
	return n;
}
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	53                   	push   %ebx
  800c97:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800ca5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ca8:	42                   	inc    %edx
  800ca9:	84 c9                	test   %cl,%cl
  800cab:	75 f5                	jne    800ca2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800cad:	5b                   	pop    %ebx
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	53                   	push   %ebx
  800cb4:	83 ec 08             	sub    $0x8,%esp
  800cb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cba:	89 1c 24             	mov    %ebx,(%esp)
  800cbd:	e8 9e ff ff ff       	call   800c60 <strlen>
	strcpy(dst + len, src);
  800cc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cc9:	01 d8                	add    %ebx,%eax
  800ccb:	89 04 24             	mov    %eax,(%esp)
  800cce:	e8 c0 ff ff ff       	call   800c93 <strcpy>
	return dst;
}
  800cd3:	89 d8                	mov    %ebx,%eax
  800cd5:	83 c4 08             	add    $0x8,%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ce6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cee:	eb 0c                	jmp    800cfc <strncpy+0x21>
		*dst++ = *src;
  800cf0:	8a 1a                	mov    (%edx),%bl
  800cf2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cf5:	80 3a 01             	cmpb   $0x1,(%edx)
  800cf8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cfb:	41                   	inc    %ecx
  800cfc:	39 f1                	cmp    %esi,%ecx
  800cfe:	75 f0                	jne    800cf0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	8b 75 08             	mov    0x8(%ebp),%esi
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d12:	85 d2                	test   %edx,%edx
  800d14:	75 0a                	jne    800d20 <strlcpy+0x1c>
  800d16:	89 f0                	mov    %esi,%eax
  800d18:	eb 1a                	jmp    800d34 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d1a:	88 18                	mov    %bl,(%eax)
  800d1c:	40                   	inc    %eax
  800d1d:	41                   	inc    %ecx
  800d1e:	eb 02                	jmp    800d22 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d20:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800d22:	4a                   	dec    %edx
  800d23:	74 0a                	je     800d2f <strlcpy+0x2b>
  800d25:	8a 19                	mov    (%ecx),%bl
  800d27:	84 db                	test   %bl,%bl
  800d29:	75 ef                	jne    800d1a <strlcpy+0x16>
  800d2b:	89 c2                	mov    %eax,%edx
  800d2d:	eb 02                	jmp    800d31 <strlcpy+0x2d>
  800d2f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800d31:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d34:	29 f0                	sub    %esi,%eax
}
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d40:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d43:	eb 02                	jmp    800d47 <strcmp+0xd>
		p++, q++;
  800d45:	41                   	inc    %ecx
  800d46:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d47:	8a 01                	mov    (%ecx),%al
  800d49:	84 c0                	test   %al,%al
  800d4b:	74 04                	je     800d51 <strcmp+0x17>
  800d4d:	3a 02                	cmp    (%edx),%al
  800d4f:	74 f4                	je     800d45 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d51:	0f b6 c0             	movzbl %al,%eax
  800d54:	0f b6 12             	movzbl (%edx),%edx
  800d57:	29 d0                	sub    %edx,%eax
}
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	53                   	push   %ebx
  800d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d65:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800d68:	eb 03                	jmp    800d6d <strncmp+0x12>
		n--, p++, q++;
  800d6a:	4a                   	dec    %edx
  800d6b:	40                   	inc    %eax
  800d6c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d6d:	85 d2                	test   %edx,%edx
  800d6f:	74 14                	je     800d85 <strncmp+0x2a>
  800d71:	8a 18                	mov    (%eax),%bl
  800d73:	84 db                	test   %bl,%bl
  800d75:	74 04                	je     800d7b <strncmp+0x20>
  800d77:	3a 19                	cmp    (%ecx),%bl
  800d79:	74 ef                	je     800d6a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d7b:	0f b6 00             	movzbl (%eax),%eax
  800d7e:	0f b6 11             	movzbl (%ecx),%edx
  800d81:	29 d0                	sub    %edx,%eax
  800d83:	eb 05                	jmp    800d8a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d85:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d8a:	5b                   	pop    %ebx
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	8b 45 08             	mov    0x8(%ebp),%eax
  800d93:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d96:	eb 05                	jmp    800d9d <strchr+0x10>
		if (*s == c)
  800d98:	38 ca                	cmp    %cl,%dl
  800d9a:	74 0c                	je     800da8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d9c:	40                   	inc    %eax
  800d9d:	8a 10                	mov    (%eax),%dl
  800d9f:	84 d2                	test   %dl,%dl
  800da1:	75 f5                	jne    800d98 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800da3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	8b 45 08             	mov    0x8(%ebp),%eax
  800db0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800db3:	eb 05                	jmp    800dba <strfind+0x10>
		if (*s == c)
  800db5:	38 ca                	cmp    %cl,%dl
  800db7:	74 07                	je     800dc0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800db9:	40                   	inc    %eax
  800dba:	8a 10                	mov    (%eax),%dl
  800dbc:	84 d2                	test   %dl,%dl
  800dbe:	75 f5                	jne    800db5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800dd1:	85 c9                	test   %ecx,%ecx
  800dd3:	74 30                	je     800e05 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dd5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ddb:	75 25                	jne    800e02 <memset+0x40>
  800ddd:	f6 c1 03             	test   $0x3,%cl
  800de0:	75 20                	jne    800e02 <memset+0x40>
		c &= 0xFF;
  800de2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800de5:	89 d3                	mov    %edx,%ebx
  800de7:	c1 e3 08             	shl    $0x8,%ebx
  800dea:	89 d6                	mov    %edx,%esi
  800dec:	c1 e6 18             	shl    $0x18,%esi
  800def:	89 d0                	mov    %edx,%eax
  800df1:	c1 e0 10             	shl    $0x10,%eax
  800df4:	09 f0                	or     %esi,%eax
  800df6:	09 d0                	or     %edx,%eax
  800df8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dfa:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800dfd:	fc                   	cld    
  800dfe:	f3 ab                	rep stos %eax,%es:(%edi)
  800e00:	eb 03                	jmp    800e05 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e02:	fc                   	cld    
  800e03:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e05:	89 f8                	mov    %edi,%eax
  800e07:	5b                   	pop    %ebx
  800e08:	5e                   	pop    %esi
  800e09:	5f                   	pop    %edi
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	57                   	push   %edi
  800e10:	56                   	push   %esi
  800e11:	8b 45 08             	mov    0x8(%ebp),%eax
  800e14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e17:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e1a:	39 c6                	cmp    %eax,%esi
  800e1c:	73 34                	jae    800e52 <memmove+0x46>
  800e1e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e21:	39 d0                	cmp    %edx,%eax
  800e23:	73 2d                	jae    800e52 <memmove+0x46>
		s += n;
		d += n;
  800e25:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e28:	f6 c2 03             	test   $0x3,%dl
  800e2b:	75 1b                	jne    800e48 <memmove+0x3c>
  800e2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e33:	75 13                	jne    800e48 <memmove+0x3c>
  800e35:	f6 c1 03             	test   $0x3,%cl
  800e38:	75 0e                	jne    800e48 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e3a:	83 ef 04             	sub    $0x4,%edi
  800e3d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e40:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e43:	fd                   	std    
  800e44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e46:	eb 07                	jmp    800e4f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e48:	4f                   	dec    %edi
  800e49:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e4c:	fd                   	std    
  800e4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e4f:	fc                   	cld    
  800e50:	eb 20                	jmp    800e72 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e52:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e58:	75 13                	jne    800e6d <memmove+0x61>
  800e5a:	a8 03                	test   $0x3,%al
  800e5c:	75 0f                	jne    800e6d <memmove+0x61>
  800e5e:	f6 c1 03             	test   $0x3,%cl
  800e61:	75 0a                	jne    800e6d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e63:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e66:	89 c7                	mov    %eax,%edi
  800e68:	fc                   	cld    
  800e69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e6b:	eb 05                	jmp    800e72 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e6d:	89 c7                	mov    %eax,%edi
  800e6f:	fc                   	cld    
  800e70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800e7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8d:	89 04 24             	mov    %eax,(%esp)
  800e90:	e8 77 ff ff ff       	call   800e0c <memmove>
}
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    

00800e97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	57                   	push   %edi
  800e9b:	56                   	push   %esi
  800e9c:	53                   	push   %ebx
  800e9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ea0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ea3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ea6:	ba 00 00 00 00       	mov    $0x0,%edx
  800eab:	eb 16                	jmp    800ec3 <memcmp+0x2c>
		if (*s1 != *s2)
  800ead:	8a 04 17             	mov    (%edi,%edx,1),%al
  800eb0:	42                   	inc    %edx
  800eb1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800eb5:	38 c8                	cmp    %cl,%al
  800eb7:	74 0a                	je     800ec3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800eb9:	0f b6 c0             	movzbl %al,%eax
  800ebc:	0f b6 c9             	movzbl %cl,%ecx
  800ebf:	29 c8                	sub    %ecx,%eax
  800ec1:	eb 09                	jmp    800ecc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ec3:	39 da                	cmp    %ebx,%edx
  800ec5:	75 e6                	jne    800ead <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ec7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ecc:	5b                   	pop    %ebx
  800ecd:	5e                   	pop    %esi
  800ece:	5f                   	pop    %edi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800eda:	89 c2                	mov    %eax,%edx
  800edc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800edf:	eb 05                	jmp    800ee6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ee1:	38 08                	cmp    %cl,(%eax)
  800ee3:	74 05                	je     800eea <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ee5:	40                   	inc    %eax
  800ee6:	39 d0                	cmp    %edx,%eax
  800ee8:	72 f7                	jb     800ee1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	57                   	push   %edi
  800ef0:	56                   	push   %esi
  800ef1:	53                   	push   %ebx
  800ef2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ef8:	eb 01                	jmp    800efb <strtol+0xf>
		s++;
  800efa:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800efb:	8a 02                	mov    (%edx),%al
  800efd:	3c 20                	cmp    $0x20,%al
  800eff:	74 f9                	je     800efa <strtol+0xe>
  800f01:	3c 09                	cmp    $0x9,%al
  800f03:	74 f5                	je     800efa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f05:	3c 2b                	cmp    $0x2b,%al
  800f07:	75 08                	jne    800f11 <strtol+0x25>
		s++;
  800f09:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f0a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f0f:	eb 13                	jmp    800f24 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f11:	3c 2d                	cmp    $0x2d,%al
  800f13:	75 0a                	jne    800f1f <strtol+0x33>
		s++, neg = 1;
  800f15:	8d 52 01             	lea    0x1(%edx),%edx
  800f18:	bf 01 00 00 00       	mov    $0x1,%edi
  800f1d:	eb 05                	jmp    800f24 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f1f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f24:	85 db                	test   %ebx,%ebx
  800f26:	74 05                	je     800f2d <strtol+0x41>
  800f28:	83 fb 10             	cmp    $0x10,%ebx
  800f2b:	75 28                	jne    800f55 <strtol+0x69>
  800f2d:	8a 02                	mov    (%edx),%al
  800f2f:	3c 30                	cmp    $0x30,%al
  800f31:	75 10                	jne    800f43 <strtol+0x57>
  800f33:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f37:	75 0a                	jne    800f43 <strtol+0x57>
		s += 2, base = 16;
  800f39:	83 c2 02             	add    $0x2,%edx
  800f3c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f41:	eb 12                	jmp    800f55 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800f43:	85 db                	test   %ebx,%ebx
  800f45:	75 0e                	jne    800f55 <strtol+0x69>
  800f47:	3c 30                	cmp    $0x30,%al
  800f49:	75 05                	jne    800f50 <strtol+0x64>
		s++, base = 8;
  800f4b:	42                   	inc    %edx
  800f4c:	b3 08                	mov    $0x8,%bl
  800f4e:	eb 05                	jmp    800f55 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800f50:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f55:	b8 00 00 00 00       	mov    $0x0,%eax
  800f5a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f5c:	8a 0a                	mov    (%edx),%cl
  800f5e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f61:	80 fb 09             	cmp    $0x9,%bl
  800f64:	77 08                	ja     800f6e <strtol+0x82>
			dig = *s - '0';
  800f66:	0f be c9             	movsbl %cl,%ecx
  800f69:	83 e9 30             	sub    $0x30,%ecx
  800f6c:	eb 1e                	jmp    800f8c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f6e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f71:	80 fb 19             	cmp    $0x19,%bl
  800f74:	77 08                	ja     800f7e <strtol+0x92>
			dig = *s - 'a' + 10;
  800f76:	0f be c9             	movsbl %cl,%ecx
  800f79:	83 e9 57             	sub    $0x57,%ecx
  800f7c:	eb 0e                	jmp    800f8c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f7e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f81:	80 fb 19             	cmp    $0x19,%bl
  800f84:	77 12                	ja     800f98 <strtol+0xac>
			dig = *s - 'A' + 10;
  800f86:	0f be c9             	movsbl %cl,%ecx
  800f89:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f8c:	39 f1                	cmp    %esi,%ecx
  800f8e:	7d 0c                	jge    800f9c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800f90:	42                   	inc    %edx
  800f91:	0f af c6             	imul   %esi,%eax
  800f94:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f96:	eb c4                	jmp    800f5c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f98:	89 c1                	mov    %eax,%ecx
  800f9a:	eb 02                	jmp    800f9e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f9c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f9e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fa2:	74 05                	je     800fa9 <strtol+0xbd>
		*endptr = (char *) s;
  800fa4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fa7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800fa9:	85 ff                	test   %edi,%edi
  800fab:	74 04                	je     800fb1 <strtol+0xc5>
  800fad:	89 c8                	mov    %ecx,%eax
  800faf:	f7 d8                	neg    %eax
}
  800fb1:	5b                   	pop    %ebx
  800fb2:	5e                   	pop    %esi
  800fb3:	5f                   	pop    %edi
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    
	...

00800fb8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	57                   	push   %edi
  800fbc:	56                   	push   %esi
  800fbd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc9:	89 c3                	mov    %eax,%ebx
  800fcb:	89 c7                	mov    %eax,%edi
  800fcd:	89 c6                	mov    %eax,%esi
  800fcf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fd1:	5b                   	pop    %ebx
  800fd2:	5e                   	pop    %esi
  800fd3:	5f                   	pop    %edi
  800fd4:	5d                   	pop    %ebp
  800fd5:	c3                   	ret    

00800fd6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	57                   	push   %edi
  800fda:	56                   	push   %esi
  800fdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe1:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe6:	89 d1                	mov    %edx,%ecx
  800fe8:	89 d3                	mov    %edx,%ebx
  800fea:	89 d7                	mov    %edx,%edi
  800fec:	89 d6                	mov    %edx,%esi
  800fee:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ff0:	5b                   	pop    %ebx
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	57                   	push   %edi
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
  800ffb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801003:	b8 03 00 00 00       	mov    $0x3,%eax
  801008:	8b 55 08             	mov    0x8(%ebp),%edx
  80100b:	89 cb                	mov    %ecx,%ebx
  80100d:	89 cf                	mov    %ecx,%edi
  80100f:	89 ce                	mov    %ecx,%esi
  801011:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801013:	85 c0                	test   %eax,%eax
  801015:	7e 28                	jle    80103f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801017:	89 44 24 10          	mov    %eax,0x10(%esp)
  80101b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801022:	00 
  801023:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  80102a:	00 
  80102b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801032:	00 
  801033:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  80103a:	e8 91 f5 ff ff       	call   8005d0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80103f:	83 c4 2c             	add    $0x2c,%esp
  801042:	5b                   	pop    %ebx
  801043:	5e                   	pop    %esi
  801044:	5f                   	pop    %edi
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    

00801047 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	57                   	push   %edi
  80104b:	56                   	push   %esi
  80104c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104d:	ba 00 00 00 00       	mov    $0x0,%edx
  801052:	b8 02 00 00 00       	mov    $0x2,%eax
  801057:	89 d1                	mov    %edx,%ecx
  801059:	89 d3                	mov    %edx,%ebx
  80105b:	89 d7                	mov    %edx,%edi
  80105d:	89 d6                	mov    %edx,%esi
  80105f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5f                   	pop    %edi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <sys_yield>:

void
sys_yield(void)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	57                   	push   %edi
  80106a:	56                   	push   %esi
  80106b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106c:	ba 00 00 00 00       	mov    $0x0,%edx
  801071:	b8 0a 00 00 00       	mov    $0xa,%eax
  801076:	89 d1                	mov    %edx,%ecx
  801078:	89 d3                	mov    %edx,%ebx
  80107a:	89 d7                	mov    %edx,%edi
  80107c:	89 d6                	mov    %edx,%esi
  80107e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801080:	5b                   	pop    %ebx
  801081:	5e                   	pop    %esi
  801082:	5f                   	pop    %edi
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    

00801085 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	57                   	push   %edi
  801089:	56                   	push   %esi
  80108a:	53                   	push   %ebx
  80108b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80108e:	be 00 00 00 00       	mov    $0x0,%esi
  801093:	b8 04 00 00 00       	mov    $0x4,%eax
  801098:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80109b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109e:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a1:	89 f7                	mov    %esi,%edi
  8010a3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010a5:	85 c0                	test   %eax,%eax
  8010a7:	7e 28                	jle    8010d1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ad:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8010b4:	00 
  8010b5:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  8010bc:	00 
  8010bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010c4:	00 
  8010c5:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  8010cc:	e8 ff f4 ff ff       	call   8005d0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010d1:	83 c4 2c             	add    $0x2c,%esp
  8010d4:	5b                   	pop    %ebx
  8010d5:	5e                   	pop    %esi
  8010d6:	5f                   	pop    %edi
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	57                   	push   %edi
  8010dd:	56                   	push   %esi
  8010de:	53                   	push   %ebx
  8010df:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8010e7:	8b 75 18             	mov    0x18(%ebp),%esi
  8010ea:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	7e 28                	jle    801124 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  801100:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801107:	00 
  801108:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  80110f:	00 
  801110:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801117:	00 
  801118:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  80111f:	e8 ac f4 ff ff       	call   8005d0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801124:	83 c4 2c             	add    $0x2c,%esp
  801127:	5b                   	pop    %ebx
  801128:	5e                   	pop    %esi
  801129:	5f                   	pop    %edi
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    

0080112c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	57                   	push   %edi
  801130:	56                   	push   %esi
  801131:	53                   	push   %ebx
  801132:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801135:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113a:	b8 06 00 00 00       	mov    $0x6,%eax
  80113f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801142:	8b 55 08             	mov    0x8(%ebp),%edx
  801145:	89 df                	mov    %ebx,%edi
  801147:	89 de                	mov    %ebx,%esi
  801149:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80114b:	85 c0                	test   %eax,%eax
  80114d:	7e 28                	jle    801177 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80114f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801153:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80115a:	00 
  80115b:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  801162:	00 
  801163:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80116a:	00 
  80116b:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  801172:	e8 59 f4 ff ff       	call   8005d0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801177:	83 c4 2c             	add    $0x2c,%esp
  80117a:	5b                   	pop    %ebx
  80117b:	5e                   	pop    %esi
  80117c:	5f                   	pop    %edi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	57                   	push   %edi
  801183:	56                   	push   %esi
  801184:	53                   	push   %ebx
  801185:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801188:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118d:	b8 08 00 00 00       	mov    $0x8,%eax
  801192:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801195:	8b 55 08             	mov    0x8(%ebp),%edx
  801198:	89 df                	mov    %ebx,%edi
  80119a:	89 de                	mov    %ebx,%esi
  80119c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	7e 28                	jle    8011ca <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011a6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8011ad:	00 
  8011ae:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  8011b5:	00 
  8011b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011bd:	00 
  8011be:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  8011c5:	e8 06 f4 ff ff       	call   8005d0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011ca:	83 c4 2c             	add    $0x2c,%esp
  8011cd:	5b                   	pop    %ebx
  8011ce:	5e                   	pop    %esi
  8011cf:	5f                   	pop    %edi
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	57                   	push   %edi
  8011d6:	56                   	push   %esi
  8011d7:	53                   	push   %ebx
  8011d8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e0:	b8 09 00 00 00       	mov    $0x9,%eax
  8011e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011eb:	89 df                	mov    %ebx,%edi
  8011ed:	89 de                	mov    %ebx,%esi
  8011ef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	7e 28                	jle    80121d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011f9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801200:	00 
  801201:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  801208:	00 
  801209:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801210:	00 
  801211:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  801218:	e8 b3 f3 ff ff       	call   8005d0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80121d:	83 c4 2c             	add    $0x2c,%esp
  801220:	5b                   	pop    %ebx
  801221:	5e                   	pop    %esi
  801222:	5f                   	pop    %edi
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	57                   	push   %edi
  801229:	56                   	push   %esi
  80122a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80122b:	be 00 00 00 00       	mov    $0x0,%esi
  801230:	b8 0b 00 00 00       	mov    $0xb,%eax
  801235:	8b 7d 14             	mov    0x14(%ebp),%edi
  801238:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80123b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80123e:	8b 55 08             	mov    0x8(%ebp),%edx
  801241:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801243:	5b                   	pop    %ebx
  801244:	5e                   	pop    %esi
  801245:	5f                   	pop    %edi
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	57                   	push   %edi
  80124c:	56                   	push   %esi
  80124d:	53                   	push   %ebx
  80124e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801251:	b9 00 00 00 00       	mov    $0x0,%ecx
  801256:	b8 0c 00 00 00       	mov    $0xc,%eax
  80125b:	8b 55 08             	mov    0x8(%ebp),%edx
  80125e:	89 cb                	mov    %ecx,%ebx
  801260:	89 cf                	mov    %ecx,%edi
  801262:	89 ce                	mov    %ecx,%esi
  801264:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801266:	85 c0                	test   %eax,%eax
  801268:	7e 28                	jle    801292 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80126a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80126e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801275:	00 
  801276:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  80127d:	00 
  80127e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801285:	00 
  801286:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  80128d:	e8 3e f3 ff ff       	call   8005d0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801292:	83 c4 2c             	add    $0x2c,%esp
  801295:	5b                   	pop    %ebx
  801296:	5e                   	pop    %esi
  801297:	5f                   	pop    %edi
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    
	...

0080129c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012a2:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  8012a9:	0f 85 80 00 00 00    	jne    80132f <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  8012af:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  8012b4:	8b 40 48             	mov    0x48(%eax),%eax
  8012b7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012be:	00 
  8012bf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012c6:	ee 
  8012c7:	89 04 24             	mov    %eax,(%esp)
  8012ca:	e8 b6 fd ff ff       	call   801085 <sys_page_alloc>
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	79 20                	jns    8012f3 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  8012d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012d7:	c7 44 24 08 70 19 80 	movl   $0x801970,0x8(%esp)
  8012de:	00 
  8012df:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8012e6:	00 
  8012e7:	c7 04 24 cc 19 80 00 	movl   $0x8019cc,(%esp)
  8012ee:	e8 dd f2 ff ff       	call   8005d0 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  8012f3:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  8012f8:	8b 40 48             	mov    0x48(%eax),%eax
  8012fb:	c7 44 24 04 3c 13 80 	movl   $0x80133c,0x4(%esp)
  801302:	00 
  801303:	89 04 24             	mov    %eax,(%esp)
  801306:	e8 c7 fe ff ff       	call   8011d2 <sys_env_set_pgfault_upcall>
  80130b:	85 c0                	test   %eax,%eax
  80130d:	79 20                	jns    80132f <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  80130f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801313:	c7 44 24 08 9c 19 80 	movl   $0x80199c,0x8(%esp)
  80131a:	00 
  80131b:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801322:	00 
  801323:	c7 04 24 cc 19 80 00 	movl   $0x8019cc,(%esp)
  80132a:	e8 a1 f2 ff ff       	call   8005d0 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80132f:	8b 45 08             	mov    0x8(%ebp),%eax
  801332:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  801337:	c9                   	leave  
  801338:	c3                   	ret    
  801339:	00 00                	add    %al,(%eax)
	...

0080133c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80133c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80133d:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  801342:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801344:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  801347:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  80134b:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  80134d:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  801350:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  801351:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  801354:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  801356:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  801359:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  80135a:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  80135d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80135e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80135f:	c3                   	ret    

00801360 <__udivdi3>:
  801360:	55                   	push   %ebp
  801361:	57                   	push   %edi
  801362:	56                   	push   %esi
  801363:	83 ec 10             	sub    $0x10,%esp
  801366:	8b 74 24 20          	mov    0x20(%esp),%esi
  80136a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80136e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801372:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801376:	89 cd                	mov    %ecx,%ebp
  801378:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  80137c:	85 c0                	test   %eax,%eax
  80137e:	75 2c                	jne    8013ac <__udivdi3+0x4c>
  801380:	39 f9                	cmp    %edi,%ecx
  801382:	77 68                	ja     8013ec <__udivdi3+0x8c>
  801384:	85 c9                	test   %ecx,%ecx
  801386:	75 0b                	jne    801393 <__udivdi3+0x33>
  801388:	b8 01 00 00 00       	mov    $0x1,%eax
  80138d:	31 d2                	xor    %edx,%edx
  80138f:	f7 f1                	div    %ecx
  801391:	89 c1                	mov    %eax,%ecx
  801393:	31 d2                	xor    %edx,%edx
  801395:	89 f8                	mov    %edi,%eax
  801397:	f7 f1                	div    %ecx
  801399:	89 c7                	mov    %eax,%edi
  80139b:	89 f0                	mov    %esi,%eax
  80139d:	f7 f1                	div    %ecx
  80139f:	89 c6                	mov    %eax,%esi
  8013a1:	89 f0                	mov    %esi,%eax
  8013a3:	89 fa                	mov    %edi,%edx
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	5e                   	pop    %esi
  8013a9:	5f                   	pop    %edi
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    
  8013ac:	39 f8                	cmp    %edi,%eax
  8013ae:	77 2c                	ja     8013dc <__udivdi3+0x7c>
  8013b0:	0f bd f0             	bsr    %eax,%esi
  8013b3:	83 f6 1f             	xor    $0x1f,%esi
  8013b6:	75 4c                	jne    801404 <__udivdi3+0xa4>
  8013b8:	39 f8                	cmp    %edi,%eax
  8013ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8013bf:	72 0a                	jb     8013cb <__udivdi3+0x6b>
  8013c1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8013c5:	0f 87 ad 00 00 00    	ja     801478 <__udivdi3+0x118>
  8013cb:	be 01 00 00 00       	mov    $0x1,%esi
  8013d0:	89 f0                	mov    %esi,%eax
  8013d2:	89 fa                	mov    %edi,%edx
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	5e                   	pop    %esi
  8013d8:	5f                   	pop    %edi
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    
  8013db:	90                   	nop
  8013dc:	31 ff                	xor    %edi,%edi
  8013de:	31 f6                	xor    %esi,%esi
  8013e0:	89 f0                	mov    %esi,%eax
  8013e2:	89 fa                	mov    %edi,%edx
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	5e                   	pop    %esi
  8013e8:	5f                   	pop    %edi
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    
  8013eb:	90                   	nop
  8013ec:	89 fa                	mov    %edi,%edx
  8013ee:	89 f0                	mov    %esi,%eax
  8013f0:	f7 f1                	div    %ecx
  8013f2:	89 c6                	mov    %eax,%esi
  8013f4:	31 ff                	xor    %edi,%edi
  8013f6:	89 f0                	mov    %esi,%eax
  8013f8:	89 fa                	mov    %edi,%edx
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	5e                   	pop    %esi
  8013fe:	5f                   	pop    %edi
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    
  801401:	8d 76 00             	lea    0x0(%esi),%esi
  801404:	89 f1                	mov    %esi,%ecx
  801406:	d3 e0                	shl    %cl,%eax
  801408:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80140c:	b8 20 00 00 00       	mov    $0x20,%eax
  801411:	29 f0                	sub    %esi,%eax
  801413:	89 ea                	mov    %ebp,%edx
  801415:	88 c1                	mov    %al,%cl
  801417:	d3 ea                	shr    %cl,%edx
  801419:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80141d:	09 ca                	or     %ecx,%edx
  80141f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801423:	89 f1                	mov    %esi,%ecx
  801425:	d3 e5                	shl    %cl,%ebp
  801427:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80142b:	89 fd                	mov    %edi,%ebp
  80142d:	88 c1                	mov    %al,%cl
  80142f:	d3 ed                	shr    %cl,%ebp
  801431:	89 fa                	mov    %edi,%edx
  801433:	89 f1                	mov    %esi,%ecx
  801435:	d3 e2                	shl    %cl,%edx
  801437:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80143b:	88 c1                	mov    %al,%cl
  80143d:	d3 ef                	shr    %cl,%edi
  80143f:	09 d7                	or     %edx,%edi
  801441:	89 f8                	mov    %edi,%eax
  801443:	89 ea                	mov    %ebp,%edx
  801445:	f7 74 24 08          	divl   0x8(%esp)
  801449:	89 d1                	mov    %edx,%ecx
  80144b:	89 c7                	mov    %eax,%edi
  80144d:	f7 64 24 0c          	mull   0xc(%esp)
  801451:	39 d1                	cmp    %edx,%ecx
  801453:	72 17                	jb     80146c <__udivdi3+0x10c>
  801455:	74 09                	je     801460 <__udivdi3+0x100>
  801457:	89 fe                	mov    %edi,%esi
  801459:	31 ff                	xor    %edi,%edi
  80145b:	e9 41 ff ff ff       	jmp    8013a1 <__udivdi3+0x41>
  801460:	8b 54 24 04          	mov    0x4(%esp),%edx
  801464:	89 f1                	mov    %esi,%ecx
  801466:	d3 e2                	shl    %cl,%edx
  801468:	39 c2                	cmp    %eax,%edx
  80146a:	73 eb                	jae    801457 <__udivdi3+0xf7>
  80146c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80146f:	31 ff                	xor    %edi,%edi
  801471:	e9 2b ff ff ff       	jmp    8013a1 <__udivdi3+0x41>
  801476:	66 90                	xchg   %ax,%ax
  801478:	31 f6                	xor    %esi,%esi
  80147a:	e9 22 ff ff ff       	jmp    8013a1 <__udivdi3+0x41>
	...

00801480 <__umoddi3>:
  801480:	55                   	push   %ebp
  801481:	57                   	push   %edi
  801482:	56                   	push   %esi
  801483:	83 ec 20             	sub    $0x20,%esp
  801486:	8b 44 24 30          	mov    0x30(%esp),%eax
  80148a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80148e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801492:	8b 74 24 34          	mov    0x34(%esp),%esi
  801496:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80149a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80149e:	89 c7                	mov    %eax,%edi
  8014a0:	89 f2                	mov    %esi,%edx
  8014a2:	85 ed                	test   %ebp,%ebp
  8014a4:	75 16                	jne    8014bc <__umoddi3+0x3c>
  8014a6:	39 f1                	cmp    %esi,%ecx
  8014a8:	0f 86 a6 00 00 00    	jbe    801554 <__umoddi3+0xd4>
  8014ae:	f7 f1                	div    %ecx
  8014b0:	89 d0                	mov    %edx,%eax
  8014b2:	31 d2                	xor    %edx,%edx
  8014b4:	83 c4 20             	add    $0x20,%esp
  8014b7:	5e                   	pop    %esi
  8014b8:	5f                   	pop    %edi
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    
  8014bb:	90                   	nop
  8014bc:	39 f5                	cmp    %esi,%ebp
  8014be:	0f 87 ac 00 00 00    	ja     801570 <__umoddi3+0xf0>
  8014c4:	0f bd c5             	bsr    %ebp,%eax
  8014c7:	83 f0 1f             	xor    $0x1f,%eax
  8014ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014ce:	0f 84 a8 00 00 00    	je     80157c <__umoddi3+0xfc>
  8014d4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014d8:	d3 e5                	shl    %cl,%ebp
  8014da:	bf 20 00 00 00       	mov    $0x20,%edi
  8014df:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8014e3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014e7:	89 f9                	mov    %edi,%ecx
  8014e9:	d3 e8                	shr    %cl,%eax
  8014eb:	09 e8                	or     %ebp,%eax
  8014ed:	89 44 24 18          	mov    %eax,0x18(%esp)
  8014f1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014f5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014f9:	d3 e0                	shl    %cl,%eax
  8014fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ff:	89 f2                	mov    %esi,%edx
  801501:	d3 e2                	shl    %cl,%edx
  801503:	8b 44 24 14          	mov    0x14(%esp),%eax
  801507:	d3 e0                	shl    %cl,%eax
  801509:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80150d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801511:	89 f9                	mov    %edi,%ecx
  801513:	d3 e8                	shr    %cl,%eax
  801515:	09 d0                	or     %edx,%eax
  801517:	d3 ee                	shr    %cl,%esi
  801519:	89 f2                	mov    %esi,%edx
  80151b:	f7 74 24 18          	divl   0x18(%esp)
  80151f:	89 d6                	mov    %edx,%esi
  801521:	f7 64 24 0c          	mull   0xc(%esp)
  801525:	89 c5                	mov    %eax,%ebp
  801527:	89 d1                	mov    %edx,%ecx
  801529:	39 d6                	cmp    %edx,%esi
  80152b:	72 67                	jb     801594 <__umoddi3+0x114>
  80152d:	74 75                	je     8015a4 <__umoddi3+0x124>
  80152f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801533:	29 e8                	sub    %ebp,%eax
  801535:	19 ce                	sbb    %ecx,%esi
  801537:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80153b:	d3 e8                	shr    %cl,%eax
  80153d:	89 f2                	mov    %esi,%edx
  80153f:	89 f9                	mov    %edi,%ecx
  801541:	d3 e2                	shl    %cl,%edx
  801543:	09 d0                	or     %edx,%eax
  801545:	89 f2                	mov    %esi,%edx
  801547:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80154b:	d3 ea                	shr    %cl,%edx
  80154d:	83 c4 20             	add    $0x20,%esp
  801550:	5e                   	pop    %esi
  801551:	5f                   	pop    %edi
  801552:	5d                   	pop    %ebp
  801553:	c3                   	ret    
  801554:	85 c9                	test   %ecx,%ecx
  801556:	75 0b                	jne    801563 <__umoddi3+0xe3>
  801558:	b8 01 00 00 00       	mov    $0x1,%eax
  80155d:	31 d2                	xor    %edx,%edx
  80155f:	f7 f1                	div    %ecx
  801561:	89 c1                	mov    %eax,%ecx
  801563:	89 f0                	mov    %esi,%eax
  801565:	31 d2                	xor    %edx,%edx
  801567:	f7 f1                	div    %ecx
  801569:	89 f8                	mov    %edi,%eax
  80156b:	e9 3e ff ff ff       	jmp    8014ae <__umoddi3+0x2e>
  801570:	89 f2                	mov    %esi,%edx
  801572:	83 c4 20             	add    $0x20,%esp
  801575:	5e                   	pop    %esi
  801576:	5f                   	pop    %edi
  801577:	5d                   	pop    %ebp
  801578:	c3                   	ret    
  801579:	8d 76 00             	lea    0x0(%esi),%esi
  80157c:	39 f5                	cmp    %esi,%ebp
  80157e:	72 04                	jb     801584 <__umoddi3+0x104>
  801580:	39 f9                	cmp    %edi,%ecx
  801582:	77 06                	ja     80158a <__umoddi3+0x10a>
  801584:	89 f2                	mov    %esi,%edx
  801586:	29 cf                	sub    %ecx,%edi
  801588:	19 ea                	sbb    %ebp,%edx
  80158a:	89 f8                	mov    %edi,%eax
  80158c:	83 c4 20             	add    $0x20,%esp
  80158f:	5e                   	pop    %esi
  801590:	5f                   	pop    %edi
  801591:	5d                   	pop    %ebp
  801592:	c3                   	ret    
  801593:	90                   	nop
  801594:	89 d1                	mov    %edx,%ecx
  801596:	89 c5                	mov    %eax,%ebp
  801598:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80159c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8015a0:	eb 8d                	jmp    80152f <__umoddi3+0xaf>
  8015a2:	66 90                	xchg   %ax,%ax
  8015a4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8015a8:	72 ea                	jb     801594 <__umoddi3+0x114>
  8015aa:	89 f1                	mov    %esi,%ecx
  8015ac:	eb 81                	jmp    80152f <__umoddi3+0xaf>

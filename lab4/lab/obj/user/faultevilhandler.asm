
obj/user/faultevilhandler:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 57 01 00 00       	call   8001ad <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800056:	c7 44 24 04 20 00 10 	movl   $0xf0100020,0x4(%esp)
  80005d:	f0 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 90 02 00 00       	call   8002fa <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	83 ec 10             	sub    $0x10,%esp
  800080:	8b 75 08             	mov    0x8(%ebp),%esi
  800083:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800086:	e8 e4 00 00 00       	call   80016f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800097:	c1 e0 07             	shl    $0x7,%eax
  80009a:	29 d0                	sub    %edx,%eax
  80009c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a1:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a6:	85 f6                	test   %esi,%esi
  8000a8:	7e 07                	jle    8000b1 <libmain+0x39>
		binaryname = argv[0];
  8000aa:	8b 03                	mov    (%ebx),%eax
  8000ac:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b5:	89 34 24             	mov    %esi,(%esp)
  8000b8:	e8 77 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000bd:	e8 0a 00 00 00       	call   8000cc <exit>
}
  8000c2:	83 c4 10             	add    $0x10,%esp
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5d                   	pop    %ebp
  8000c8:	c3                   	ret    
  8000c9:	00 00                	add    %al,(%eax)
	...

008000cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d9:	e8 3f 00 00 00       	call   80011d <sys_env_destroy>
}
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 c3                	mov    %eax,%ebx
  8000f3:	89 c7                	mov    %eax,%edi
  8000f5:	89 c6                	mov    %eax,%esi
  8000f7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <sys_cgetc>:

int
sys_cgetc(void)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	57                   	push   %edi
  800102:	56                   	push   %esi
  800103:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800104:	ba 00 00 00 00       	mov    $0x0,%edx
  800109:	b8 01 00 00 00       	mov    $0x1,%eax
  80010e:	89 d1                	mov    %edx,%ecx
  800110:	89 d3                	mov    %edx,%ebx
  800112:	89 d7                	mov    %edx,%edi
  800114:	89 d6                	mov    %edx,%esi
  800116:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5f                   	pop    %edi
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    

0080011d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	57                   	push   %edi
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
  800123:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012b:	b8 03 00 00 00       	mov    $0x3,%eax
  800130:	8b 55 08             	mov    0x8(%ebp),%edx
  800133:	89 cb                	mov    %ecx,%ebx
  800135:	89 cf                	mov    %ecx,%edi
  800137:	89 ce                	mov    %ecx,%esi
  800139:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80013b:	85 c0                	test   %eax,%eax
  80013d:	7e 28                	jle    800167 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80013f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800143:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80014a:	00 
  80014b:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  800152:	00 
  800153:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80015a:	00 
  80015b:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  800162:	e8 5d 02 00 00       	call   8003c4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800167:	83 c4 2c             	add    $0x2c,%esp
  80016a:	5b                   	pop    %ebx
  80016b:	5e                   	pop    %esi
  80016c:	5f                   	pop    %edi
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    

0080016f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	57                   	push   %edi
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800175:	ba 00 00 00 00       	mov    $0x0,%edx
  80017a:	b8 02 00 00 00       	mov    $0x2,%eax
  80017f:	89 d1                	mov    %edx,%ecx
  800181:	89 d3                	mov    %edx,%ebx
  800183:	89 d7                	mov    %edx,%edi
  800185:	89 d6                	mov    %edx,%esi
  800187:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800189:	5b                   	pop    %ebx
  80018a:	5e                   	pop    %esi
  80018b:	5f                   	pop    %edi
  80018c:	5d                   	pop    %ebp
  80018d:	c3                   	ret    

0080018e <sys_yield>:

void
sys_yield(void)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	57                   	push   %edi
  800192:	56                   	push   %esi
  800193:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800194:	ba 00 00 00 00       	mov    $0x0,%edx
  800199:	b8 0a 00 00 00       	mov    $0xa,%eax
  80019e:	89 d1                	mov    %edx,%ecx
  8001a0:	89 d3                	mov    %edx,%ebx
  8001a2:	89 d7                	mov    %edx,%edi
  8001a4:	89 d6                	mov    %edx,%esi
  8001a6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b6:	be 00 00 00 00       	mov    $0x0,%esi
  8001bb:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c9:	89 f7                	mov    %esi,%edi
  8001cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001cd:	85 c0                	test   %eax,%eax
  8001cf:	7e 28                	jle    8001f9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001dc:	00 
  8001dd:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8001e4:	00 
  8001e5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001ec:	00 
  8001ed:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  8001f4:	e8 cb 01 00 00       	call   8003c4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001f9:	83 c4 2c             	add    $0x2c,%esp
  8001fc:	5b                   	pop    %ebx
  8001fd:	5e                   	pop    %esi
  8001fe:	5f                   	pop    %edi
  8001ff:	5d                   	pop    %ebp
  800200:	c3                   	ret    

00800201 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	57                   	push   %edi
  800205:	56                   	push   %esi
  800206:	53                   	push   %ebx
  800207:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020a:	b8 05 00 00 00       	mov    $0x5,%eax
  80020f:	8b 75 18             	mov    0x18(%ebp),%esi
  800212:	8b 7d 14             	mov    0x14(%ebp),%edi
  800215:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800218:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021b:	8b 55 08             	mov    0x8(%ebp),%edx
  80021e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800220:	85 c0                	test   %eax,%eax
  800222:	7e 28                	jle    80024c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800224:	89 44 24 10          	mov    %eax,0x10(%esp)
  800228:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80022f:	00 
  800230:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  800237:	00 
  800238:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80023f:	00 
  800240:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  800247:	e8 78 01 00 00       	call   8003c4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80024c:	83 c4 2c             	add    $0x2c,%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	5d                   	pop    %ebp
  800253:	c3                   	ret    

00800254 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	57                   	push   %edi
  800258:	56                   	push   %esi
  800259:	53                   	push   %ebx
  80025a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80025d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800262:	b8 06 00 00 00       	mov    $0x6,%eax
  800267:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026a:	8b 55 08             	mov    0x8(%ebp),%edx
  80026d:	89 df                	mov    %ebx,%edi
  80026f:	89 de                	mov    %ebx,%esi
  800271:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800273:	85 c0                	test   %eax,%eax
  800275:	7e 28                	jle    80029f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800277:	89 44 24 10          	mov    %eax,0x10(%esp)
  80027b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800282:	00 
  800283:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  80028a:	00 
  80028b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800292:	00 
  800293:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  80029a:	e8 25 01 00 00       	call   8003c4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80029f:	83 c4 2c             	add    $0x2c,%esp
  8002a2:	5b                   	pop    %ebx
  8002a3:	5e                   	pop    %esi
  8002a4:	5f                   	pop    %edi
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	57                   	push   %edi
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
  8002ad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b5:	b8 08 00 00 00       	mov    $0x8,%eax
  8002ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c0:	89 df                	mov    %ebx,%edi
  8002c2:	89 de                	mov    %ebx,%esi
  8002c4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c6:	85 c0                	test   %eax,%eax
  8002c8:	7e 28                	jle    8002f2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ce:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002d5:	00 
  8002d6:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8002dd:	00 
  8002de:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002e5:	00 
  8002e6:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  8002ed:	e8 d2 00 00 00       	call   8003c4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002f2:	83 c4 2c             	add    $0x2c,%esp
  8002f5:	5b                   	pop    %ebx
  8002f6:	5e                   	pop    %esi
  8002f7:	5f                   	pop    %edi
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    

008002fa <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	57                   	push   %edi
  8002fe:	56                   	push   %esi
  8002ff:	53                   	push   %ebx
  800300:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	bb 00 00 00 00       	mov    $0x0,%ebx
  800308:	b8 09 00 00 00       	mov    $0x9,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	89 df                	mov    %ebx,%edi
  800315:	89 de                	mov    %ebx,%esi
  800317:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800319:	85 c0                	test   %eax,%eax
  80031b:	7e 28                	jle    800345 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80031d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800321:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800328:	00 
  800329:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  800330:	00 
  800331:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800338:	00 
  800339:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  800340:	e8 7f 00 00 00       	call   8003c4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800345:	83 c4 2c             	add    $0x2c,%esp
  800348:	5b                   	pop    %ebx
  800349:	5e                   	pop    %esi
  80034a:	5f                   	pop    %edi
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	57                   	push   %edi
  800351:	56                   	push   %esi
  800352:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800353:	be 00 00 00 00       	mov    $0x0,%esi
  800358:	b8 0b 00 00 00       	mov    $0xb,%eax
  80035d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800360:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800363:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800366:	8b 55 08             	mov    0x8(%ebp),%edx
  800369:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80036b:	5b                   	pop    %ebx
  80036c:	5e                   	pop    %esi
  80036d:	5f                   	pop    %edi
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	57                   	push   %edi
  800374:	56                   	push   %esi
  800375:	53                   	push   %ebx
  800376:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800379:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800383:	8b 55 08             	mov    0x8(%ebp),%edx
  800386:	89 cb                	mov    %ecx,%ebx
  800388:	89 cf                	mov    %ecx,%edi
  80038a:	89 ce                	mov    %ecx,%esi
  80038c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80038e:	85 c0                	test   %eax,%eax
  800390:	7e 28                	jle    8003ba <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800392:	89 44 24 10          	mov    %eax,0x10(%esp)
  800396:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80039d:	00 
  80039e:	c7 44 24 08 0a 10 80 	movl   $0x80100a,0x8(%esp)
  8003a5:	00 
  8003a6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003ad:	00 
  8003ae:	c7 04 24 27 10 80 00 	movl   $0x801027,(%esp)
  8003b5:	e8 0a 00 00 00       	call   8003c4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003ba:	83 c4 2c             	add    $0x2c,%esp
  8003bd:	5b                   	pop    %ebx
  8003be:	5e                   	pop    %esi
  8003bf:	5f                   	pop    %edi
  8003c0:	5d                   	pop    %ebp
  8003c1:	c3                   	ret    
	...

008003c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	56                   	push   %esi
  8003c8:	53                   	push   %ebx
  8003c9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003cc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003cf:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003d5:	e8 95 fd ff ff       	call   80016f <sys_getenvid>
  8003da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003dd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f0:	c7 04 24 38 10 80 00 	movl   $0x801038,(%esp)
  8003f7:	e8 c0 00 00 00       	call   8004bc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800400:	8b 45 10             	mov    0x10(%ebp),%eax
  800403:	89 04 24             	mov    %eax,(%esp)
  800406:	e8 50 00 00 00       	call   80045b <vcprintf>
	cprintf("\n");
  80040b:	c7 04 24 5c 10 80 00 	movl   $0x80105c,(%esp)
  800412:	e8 a5 00 00 00       	call   8004bc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800417:	cc                   	int3   
  800418:	eb fd                	jmp    800417 <_panic+0x53>
	...

0080041c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	53                   	push   %ebx
  800420:	83 ec 14             	sub    $0x14,%esp
  800423:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800426:	8b 03                	mov    (%ebx),%eax
  800428:	8b 55 08             	mov    0x8(%ebp),%edx
  80042b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80042f:	40                   	inc    %eax
  800430:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800432:	3d ff 00 00 00       	cmp    $0xff,%eax
  800437:	75 19                	jne    800452 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800439:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800440:	00 
  800441:	8d 43 08             	lea    0x8(%ebx),%eax
  800444:	89 04 24             	mov    %eax,(%esp)
  800447:	e8 94 fc ff ff       	call   8000e0 <sys_cputs>
		b->idx = 0;
  80044c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800452:	ff 43 04             	incl   0x4(%ebx)
}
  800455:	83 c4 14             	add    $0x14,%esp
  800458:	5b                   	pop    %ebx
  800459:	5d                   	pop    %ebp
  80045a:	c3                   	ret    

0080045b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80045b:	55                   	push   %ebp
  80045c:	89 e5                	mov    %esp,%ebp
  80045e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800464:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80046b:	00 00 00 
	b.cnt = 0;
  80046e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800475:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800478:	8b 45 0c             	mov    0xc(%ebp),%eax
  80047b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80047f:	8b 45 08             	mov    0x8(%ebp),%eax
  800482:	89 44 24 08          	mov    %eax,0x8(%esp)
  800486:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80048c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800490:	c7 04 24 1c 04 80 00 	movl   $0x80041c,(%esp)
  800497:	e8 82 01 00 00       	call   80061e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80049c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ac:	89 04 24             	mov    %eax,(%esp)
  8004af:	e8 2c fc ff ff       	call   8000e0 <sys_cputs>

	return b.cnt;
}
  8004b4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004ba:	c9                   	leave  
  8004bb:	c3                   	ret    

008004bc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004c2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004cc:	89 04 24             	mov    %eax,(%esp)
  8004cf:	e8 87 ff ff ff       	call   80045b <vcprintf>
	va_end(ap);

	return cnt;
}
  8004d4:	c9                   	leave  
  8004d5:	c3                   	ret    
	...

008004d8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	57                   	push   %edi
  8004dc:	56                   	push   %esi
  8004dd:	53                   	push   %ebx
  8004de:	83 ec 3c             	sub    $0x3c,%esp
  8004e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004e4:	89 d7                	mov    %edx,%edi
  8004e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004f5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004f8:	85 c0                	test   %eax,%eax
  8004fa:	75 08                	jne    800504 <printnum+0x2c>
  8004fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ff:	39 45 10             	cmp    %eax,0x10(%ebp)
  800502:	77 57                	ja     80055b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800504:	89 74 24 10          	mov    %esi,0x10(%esp)
  800508:	4b                   	dec    %ebx
  800509:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80050d:	8b 45 10             	mov    0x10(%ebp),%eax
  800510:	89 44 24 08          	mov    %eax,0x8(%esp)
  800514:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800518:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80051c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800523:	00 
  800524:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800527:	89 04 24             	mov    %eax,(%esp)
  80052a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800531:	e8 76 08 00 00       	call   800dac <__udivdi3>
  800536:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80053a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	89 54 24 04          	mov    %edx,0x4(%esp)
  800545:	89 fa                	mov    %edi,%edx
  800547:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80054a:	e8 89 ff ff ff       	call   8004d8 <printnum>
  80054f:	eb 0f                	jmp    800560 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800551:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800555:	89 34 24             	mov    %esi,(%esp)
  800558:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80055b:	4b                   	dec    %ebx
  80055c:	85 db                	test   %ebx,%ebx
  80055e:	7f f1                	jg     800551 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800560:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800564:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800568:	8b 45 10             	mov    0x10(%ebp),%eax
  80056b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80056f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800576:	00 
  800577:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80057a:	89 04 24             	mov    %eax,(%esp)
  80057d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800580:	89 44 24 04          	mov    %eax,0x4(%esp)
  800584:	e8 43 09 00 00       	call   800ecc <__umoddi3>
  800589:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058d:	0f be 80 5e 10 80 00 	movsbl 0x80105e(%eax),%eax
  800594:	89 04 24             	mov    %eax,(%esp)
  800597:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80059a:	83 c4 3c             	add    $0x3c,%esp
  80059d:	5b                   	pop    %ebx
  80059e:	5e                   	pop    %esi
  80059f:	5f                   	pop    %edi
  8005a0:	5d                   	pop    %ebp
  8005a1:	c3                   	ret    

008005a2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005a2:	55                   	push   %ebp
  8005a3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005a5:	83 fa 01             	cmp    $0x1,%edx
  8005a8:	7e 0e                	jle    8005b8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005aa:	8b 10                	mov    (%eax),%edx
  8005ac:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005af:	89 08                	mov    %ecx,(%eax)
  8005b1:	8b 02                	mov    (%edx),%eax
  8005b3:	8b 52 04             	mov    0x4(%edx),%edx
  8005b6:	eb 22                	jmp    8005da <getuint+0x38>
	else if (lflag)
  8005b8:	85 d2                	test   %edx,%edx
  8005ba:	74 10                	je     8005cc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005bc:	8b 10                	mov    (%eax),%edx
  8005be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005c1:	89 08                	mov    %ecx,(%eax)
  8005c3:	8b 02                	mov    (%edx),%eax
  8005c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ca:	eb 0e                	jmp    8005da <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005cc:	8b 10                	mov    (%eax),%edx
  8005ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005d1:	89 08                	mov    %ecx,(%eax)
  8005d3:	8b 02                	mov    (%edx),%eax
  8005d5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005da:	5d                   	pop    %ebp
  8005db:	c3                   	ret    

008005dc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005dc:	55                   	push   %ebp
  8005dd:	89 e5                	mov    %esp,%ebp
  8005df:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005e2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005e5:	8b 10                	mov    (%eax),%edx
  8005e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ea:	73 08                	jae    8005f4 <sprintputch+0x18>
		*b->buf++ = ch;
  8005ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005ef:	88 0a                	mov    %cl,(%edx)
  8005f1:	42                   	inc    %edx
  8005f2:	89 10                	mov    %edx,(%eax)
}
  8005f4:	5d                   	pop    %ebp
  8005f5:	c3                   	ret    

008005f6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005f6:	55                   	push   %ebp
  8005f7:	89 e5                	mov    %esp,%ebp
  8005f9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005fc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800603:	8b 45 10             	mov    0x10(%ebp),%eax
  800606:	89 44 24 08          	mov    %eax,0x8(%esp)
  80060a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80060d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800611:	8b 45 08             	mov    0x8(%ebp),%eax
  800614:	89 04 24             	mov    %eax,(%esp)
  800617:	e8 02 00 00 00       	call   80061e <vprintfmt>
	va_end(ap);
}
  80061c:	c9                   	leave  
  80061d:	c3                   	ret    

0080061e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80061e:	55                   	push   %ebp
  80061f:	89 e5                	mov    %esp,%ebp
  800621:	57                   	push   %edi
  800622:	56                   	push   %esi
  800623:	53                   	push   %ebx
  800624:	83 ec 4c             	sub    $0x4c,%esp
  800627:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80062a:	8b 75 10             	mov    0x10(%ebp),%esi
  80062d:	eb 12                	jmp    800641 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80062f:	85 c0                	test   %eax,%eax
  800631:	0f 84 8b 03 00 00    	je     8009c2 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800637:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800641:	0f b6 06             	movzbl (%esi),%eax
  800644:	46                   	inc    %esi
  800645:	83 f8 25             	cmp    $0x25,%eax
  800648:	75 e5                	jne    80062f <vprintfmt+0x11>
  80064a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80064e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800655:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80065a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800661:	b9 00 00 00 00       	mov    $0x0,%ecx
  800666:	eb 26                	jmp    80068e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80066b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80066f:	eb 1d                	jmp    80068e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800671:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800674:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800678:	eb 14                	jmp    80068e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80067d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800684:	eb 08                	jmp    80068e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800686:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800689:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	0f b6 06             	movzbl (%esi),%eax
  800691:	8d 56 01             	lea    0x1(%esi),%edx
  800694:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800697:	8a 16                	mov    (%esi),%dl
  800699:	83 ea 23             	sub    $0x23,%edx
  80069c:	80 fa 55             	cmp    $0x55,%dl
  80069f:	0f 87 01 03 00 00    	ja     8009a6 <vprintfmt+0x388>
  8006a5:	0f b6 d2             	movzbl %dl,%edx
  8006a8:	ff 24 95 20 11 80 00 	jmp    *0x801120(,%edx,4)
  8006af:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006b7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8006ba:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8006be:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006c1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006c4:	83 fa 09             	cmp    $0x9,%edx
  8006c7:	77 2a                	ja     8006f3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006c9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006ca:	eb eb                	jmp    8006b7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 50 04             	lea    0x4(%eax),%edx
  8006d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006da:	eb 17                	jmp    8006f3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006e0:	78 98                	js     80067a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006e5:	eb a7                	jmp    80068e <vprintfmt+0x70>
  8006e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006ea:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006f1:	eb 9b                	jmp    80068e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006f3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006f7:	79 95                	jns    80068e <vprintfmt+0x70>
  8006f9:	eb 8b                	jmp    800686 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006fb:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006ff:	eb 8d                	jmp    80068e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 04             	lea    0x4(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070e:	8b 00                	mov    (%eax),%eax
  800710:	89 04 24             	mov    %eax,(%esp)
  800713:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800716:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800719:	e9 23 ff ff ff       	jmp    800641 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80071e:	8b 45 14             	mov    0x14(%ebp),%eax
  800721:	8d 50 04             	lea    0x4(%eax),%edx
  800724:	89 55 14             	mov    %edx,0x14(%ebp)
  800727:	8b 00                	mov    (%eax),%eax
  800729:	85 c0                	test   %eax,%eax
  80072b:	79 02                	jns    80072f <vprintfmt+0x111>
  80072d:	f7 d8                	neg    %eax
  80072f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800731:	83 f8 08             	cmp    $0x8,%eax
  800734:	7f 0b                	jg     800741 <vprintfmt+0x123>
  800736:	8b 04 85 80 12 80 00 	mov    0x801280(,%eax,4),%eax
  80073d:	85 c0                	test   %eax,%eax
  80073f:	75 23                	jne    800764 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800741:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800745:	c7 44 24 08 76 10 80 	movl   $0x801076,0x8(%esp)
  80074c:	00 
  80074d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800751:	8b 45 08             	mov    0x8(%ebp),%eax
  800754:	89 04 24             	mov    %eax,(%esp)
  800757:	e8 9a fe ff ff       	call   8005f6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80075f:	e9 dd fe ff ff       	jmp    800641 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800764:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800768:	c7 44 24 08 7f 10 80 	movl   $0x80107f,0x8(%esp)
  80076f:	00 
  800770:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800774:	8b 55 08             	mov    0x8(%ebp),%edx
  800777:	89 14 24             	mov    %edx,(%esp)
  80077a:	e8 77 fe ff ff       	call   8005f6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800782:	e9 ba fe ff ff       	jmp    800641 <vprintfmt+0x23>
  800787:	89 f9                	mov    %edi,%ecx
  800789:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80078c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8d 50 04             	lea    0x4(%eax),%edx
  800795:	89 55 14             	mov    %edx,0x14(%ebp)
  800798:	8b 30                	mov    (%eax),%esi
  80079a:	85 f6                	test   %esi,%esi
  80079c:	75 05                	jne    8007a3 <vprintfmt+0x185>
				p = "(null)";
  80079e:	be 6f 10 80 00       	mov    $0x80106f,%esi
			if (width > 0 && padc != '-')
  8007a3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a7:	0f 8e 84 00 00 00    	jle    800831 <vprintfmt+0x213>
  8007ad:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007b1:	74 7e                	je     800831 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007b7:	89 34 24             	mov    %esi,(%esp)
  8007ba:	e8 ab 02 00 00       	call   800a6a <strnlen>
  8007bf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007c2:	29 c2                	sub    %eax,%edx
  8007c4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007c7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007cb:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007ce:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007d1:	89 de                	mov    %ebx,%esi
  8007d3:	89 d3                	mov    %edx,%ebx
  8007d5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d7:	eb 0b                	jmp    8007e4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007dd:	89 3c 24             	mov    %edi,(%esp)
  8007e0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007e3:	4b                   	dec    %ebx
  8007e4:	85 db                	test   %ebx,%ebx
  8007e6:	7f f1                	jg     8007d9 <vprintfmt+0x1bb>
  8007e8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007eb:	89 f3                	mov    %esi,%ebx
  8007ed:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	79 05                	jns    8007fc <vprintfmt+0x1de>
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007ff:	29 c2                	sub    %eax,%edx
  800801:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800804:	eb 2b                	jmp    800831 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800806:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80080a:	74 18                	je     800824 <vprintfmt+0x206>
  80080c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80080f:	83 fa 5e             	cmp    $0x5e,%edx
  800812:	76 10                	jbe    800824 <vprintfmt+0x206>
					putch('?', putdat);
  800814:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800818:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80081f:	ff 55 08             	call   *0x8(%ebp)
  800822:	eb 0a                	jmp    80082e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800824:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800828:	89 04 24             	mov    %eax,(%esp)
  80082b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80082e:	ff 4d e4             	decl   -0x1c(%ebp)
  800831:	0f be 06             	movsbl (%esi),%eax
  800834:	46                   	inc    %esi
  800835:	85 c0                	test   %eax,%eax
  800837:	74 21                	je     80085a <vprintfmt+0x23c>
  800839:	85 ff                	test   %edi,%edi
  80083b:	78 c9                	js     800806 <vprintfmt+0x1e8>
  80083d:	4f                   	dec    %edi
  80083e:	79 c6                	jns    800806 <vprintfmt+0x1e8>
  800840:	8b 7d 08             	mov    0x8(%ebp),%edi
  800843:	89 de                	mov    %ebx,%esi
  800845:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800848:	eb 18                	jmp    800862 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80084a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80084e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800855:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800857:	4b                   	dec    %ebx
  800858:	eb 08                	jmp    800862 <vprintfmt+0x244>
  80085a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085d:	89 de                	mov    %ebx,%esi
  80085f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800862:	85 db                	test   %ebx,%ebx
  800864:	7f e4                	jg     80084a <vprintfmt+0x22c>
  800866:	89 7d 08             	mov    %edi,0x8(%ebp)
  800869:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80086e:	e9 ce fd ff ff       	jmp    800641 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800873:	83 f9 01             	cmp    $0x1,%ecx
  800876:	7e 10                	jle    800888 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8d 50 08             	lea    0x8(%eax),%edx
  80087e:	89 55 14             	mov    %edx,0x14(%ebp)
  800881:	8b 30                	mov    (%eax),%esi
  800883:	8b 78 04             	mov    0x4(%eax),%edi
  800886:	eb 26                	jmp    8008ae <vprintfmt+0x290>
	else if (lflag)
  800888:	85 c9                	test   %ecx,%ecx
  80088a:	74 12                	je     80089e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80088c:	8b 45 14             	mov    0x14(%ebp),%eax
  80088f:	8d 50 04             	lea    0x4(%eax),%edx
  800892:	89 55 14             	mov    %edx,0x14(%ebp)
  800895:	8b 30                	mov    (%eax),%esi
  800897:	89 f7                	mov    %esi,%edi
  800899:	c1 ff 1f             	sar    $0x1f,%edi
  80089c:	eb 10                	jmp    8008ae <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80089e:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a1:	8d 50 04             	lea    0x4(%eax),%edx
  8008a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a7:	8b 30                	mov    (%eax),%esi
  8008a9:	89 f7                	mov    %esi,%edi
  8008ab:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008ae:	85 ff                	test   %edi,%edi
  8008b0:	78 0a                	js     8008bc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008b7:	e9 ac 00 00 00       	jmp    800968 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008c7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008ca:	f7 de                	neg    %esi
  8008cc:	83 d7 00             	adc    $0x0,%edi
  8008cf:	f7 df                	neg    %edi
			}
			base = 10;
  8008d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008d6:	e9 8d 00 00 00       	jmp    800968 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008db:	89 ca                	mov    %ecx,%edx
  8008dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e0:	e8 bd fc ff ff       	call   8005a2 <getuint>
  8008e5:	89 c6                	mov    %eax,%esi
  8008e7:	89 d7                	mov    %edx,%edi
			base = 10;
  8008e9:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008ee:	eb 78                	jmp    800968 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8008f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f4:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008fb:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8008fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800902:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800909:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80090c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800910:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800917:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80091d:	e9 1f fd ff ff       	jmp    800641 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800922:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800926:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80092d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800930:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800934:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80093b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	8d 50 04             	lea    0x4(%eax),%edx
  800944:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800947:	8b 30                	mov    (%eax),%esi
  800949:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80094e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800953:	eb 13                	jmp    800968 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800955:	89 ca                	mov    %ecx,%edx
  800957:	8d 45 14             	lea    0x14(%ebp),%eax
  80095a:	e8 43 fc ff ff       	call   8005a2 <getuint>
  80095f:	89 c6                	mov    %eax,%esi
  800961:	89 d7                	mov    %edx,%edi
			base = 16;
  800963:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800968:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80096c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800970:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800973:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800977:	89 44 24 08          	mov    %eax,0x8(%esp)
  80097b:	89 34 24             	mov    %esi,(%esp)
  80097e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800982:	89 da                	mov    %ebx,%edx
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	e8 4c fb ff ff       	call   8004d8 <printnum>
			break;
  80098c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80098f:	e9 ad fc ff ff       	jmp    800641 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800994:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800998:	89 04 24             	mov    %eax,(%esp)
  80099b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009a1:	e9 9b fc ff ff       	jmp    800641 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009aa:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009b1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009b4:	eb 01                	jmp    8009b7 <vprintfmt+0x399>
  8009b6:	4e                   	dec    %esi
  8009b7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009bb:	75 f9                	jne    8009b6 <vprintfmt+0x398>
  8009bd:	e9 7f fc ff ff       	jmp    800641 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009c2:	83 c4 4c             	add    $0x4c,%esp
  8009c5:	5b                   	pop    %ebx
  8009c6:	5e                   	pop    %esi
  8009c7:	5f                   	pop    %edi
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	83 ec 28             	sub    $0x28,%esp
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009d9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009dd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009e7:	85 c0                	test   %eax,%eax
  8009e9:	74 30                	je     800a1b <vsnprintf+0x51>
  8009eb:	85 d2                	test   %edx,%edx
  8009ed:	7e 33                	jle    800a22 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009fd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a04:	c7 04 24 dc 05 80 00 	movl   $0x8005dc,(%esp)
  800a0b:	e8 0e fc ff ff       	call   80061e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a10:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a13:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a19:	eb 0c                	jmp    800a27 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a20:	eb 05                	jmp    800a27 <vsnprintf+0x5d>
  800a22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a27:	c9                   	leave  
  800a28:	c3                   	ret    

00800a29 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a2f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a32:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a36:	8b 45 10             	mov    0x10(%ebp),%eax
  800a39:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a40:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	89 04 24             	mov    %eax,(%esp)
  800a4a:	e8 7b ff ff ff       	call   8009ca <vsnprintf>
	va_end(ap);

	return rc;
}
  800a4f:	c9                   	leave  
  800a50:	c3                   	ret    
  800a51:	00 00                	add    %al,(%eax)
	...

00800a54 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5f:	eb 01                	jmp    800a62 <strlen+0xe>
		n++;
  800a61:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a62:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a66:	75 f9                	jne    800a61 <strlen+0xd>
		n++;
	return n;
}
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a70:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
  800a78:	eb 01                	jmp    800a7b <strnlen+0x11>
		n++;
  800a7a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a7b:	39 d0                	cmp    %edx,%eax
  800a7d:	74 06                	je     800a85 <strnlen+0x1b>
  800a7f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a83:	75 f5                	jne    800a7a <strnlen+0x10>
		n++;
	return n;
}
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	53                   	push   %ebx
  800a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a91:	ba 00 00 00 00       	mov    $0x0,%edx
  800a96:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a99:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a9c:	42                   	inc    %edx
  800a9d:	84 c9                	test   %cl,%cl
  800a9f:	75 f5                	jne    800a96 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	53                   	push   %ebx
  800aa8:	83 ec 08             	sub    $0x8,%esp
  800aab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aae:	89 1c 24             	mov    %ebx,(%esp)
  800ab1:	e8 9e ff ff ff       	call   800a54 <strlen>
	strcpy(dst + len, src);
  800ab6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800abd:	01 d8                	add    %ebx,%eax
  800abf:	89 04 24             	mov    %eax,(%esp)
  800ac2:	e8 c0 ff ff ff       	call   800a87 <strcpy>
	return dst;
}
  800ac7:	89 d8                	mov    %ebx,%eax
  800ac9:	83 c4 08             	add    $0x8,%esp
  800acc:	5b                   	pop    %ebx
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ada:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800add:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae2:	eb 0c                	jmp    800af0 <strncpy+0x21>
		*dst++ = *src;
  800ae4:	8a 1a                	mov    (%edx),%bl
  800ae6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ae9:	80 3a 01             	cmpb   $0x1,(%edx)
  800aec:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aef:	41                   	inc    %ecx
  800af0:	39 f1                	cmp    %esi,%ecx
  800af2:	75 f0                	jne    800ae4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	8b 75 08             	mov    0x8(%ebp),%esi
  800b00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b03:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b06:	85 d2                	test   %edx,%edx
  800b08:	75 0a                	jne    800b14 <strlcpy+0x1c>
  800b0a:	89 f0                	mov    %esi,%eax
  800b0c:	eb 1a                	jmp    800b28 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b0e:	88 18                	mov    %bl,(%eax)
  800b10:	40                   	inc    %eax
  800b11:	41                   	inc    %ecx
  800b12:	eb 02                	jmp    800b16 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b14:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b16:	4a                   	dec    %edx
  800b17:	74 0a                	je     800b23 <strlcpy+0x2b>
  800b19:	8a 19                	mov    (%ecx),%bl
  800b1b:	84 db                	test   %bl,%bl
  800b1d:	75 ef                	jne    800b0e <strlcpy+0x16>
  800b1f:	89 c2                	mov    %eax,%edx
  800b21:	eb 02                	jmp    800b25 <strlcpy+0x2d>
  800b23:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b25:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b28:	29 f0                	sub    %esi,%eax
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b34:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b37:	eb 02                	jmp    800b3b <strcmp+0xd>
		p++, q++;
  800b39:	41                   	inc    %ecx
  800b3a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b3b:	8a 01                	mov    (%ecx),%al
  800b3d:	84 c0                	test   %al,%al
  800b3f:	74 04                	je     800b45 <strcmp+0x17>
  800b41:	3a 02                	cmp    (%edx),%al
  800b43:	74 f4                	je     800b39 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b45:	0f b6 c0             	movzbl %al,%eax
  800b48:	0f b6 12             	movzbl (%edx),%edx
  800b4b:	29 d0                	sub    %edx,%eax
}
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	53                   	push   %ebx
  800b53:	8b 45 08             	mov    0x8(%ebp),%eax
  800b56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b59:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b5c:	eb 03                	jmp    800b61 <strncmp+0x12>
		n--, p++, q++;
  800b5e:	4a                   	dec    %edx
  800b5f:	40                   	inc    %eax
  800b60:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b61:	85 d2                	test   %edx,%edx
  800b63:	74 14                	je     800b79 <strncmp+0x2a>
  800b65:	8a 18                	mov    (%eax),%bl
  800b67:	84 db                	test   %bl,%bl
  800b69:	74 04                	je     800b6f <strncmp+0x20>
  800b6b:	3a 19                	cmp    (%ecx),%bl
  800b6d:	74 ef                	je     800b5e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b6f:	0f b6 00             	movzbl (%eax),%eax
  800b72:	0f b6 11             	movzbl (%ecx),%edx
  800b75:	29 d0                	sub    %edx,%eax
  800b77:	eb 05                	jmp    800b7e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b79:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
  800b87:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b8a:	eb 05                	jmp    800b91 <strchr+0x10>
		if (*s == c)
  800b8c:	38 ca                	cmp    %cl,%dl
  800b8e:	74 0c                	je     800b9c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b90:	40                   	inc    %eax
  800b91:	8a 10                	mov    (%eax),%dl
  800b93:	84 d2                	test   %dl,%dl
  800b95:	75 f5                	jne    800b8c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ba7:	eb 05                	jmp    800bae <strfind+0x10>
		if (*s == c)
  800ba9:	38 ca                	cmp    %cl,%dl
  800bab:	74 07                	je     800bb4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bad:	40                   	inc    %eax
  800bae:	8a 10                	mov    (%eax),%dl
  800bb0:	84 d2                	test   %dl,%dl
  800bb2:	75 f5                	jne    800ba9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
  800bbc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bc5:	85 c9                	test   %ecx,%ecx
  800bc7:	74 30                	je     800bf9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bc9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bcf:	75 25                	jne    800bf6 <memset+0x40>
  800bd1:	f6 c1 03             	test   $0x3,%cl
  800bd4:	75 20                	jne    800bf6 <memset+0x40>
		c &= 0xFF;
  800bd6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bd9:	89 d3                	mov    %edx,%ebx
  800bdb:	c1 e3 08             	shl    $0x8,%ebx
  800bde:	89 d6                	mov    %edx,%esi
  800be0:	c1 e6 18             	shl    $0x18,%esi
  800be3:	89 d0                	mov    %edx,%eax
  800be5:	c1 e0 10             	shl    $0x10,%eax
  800be8:	09 f0                	or     %esi,%eax
  800bea:	09 d0                	or     %edx,%eax
  800bec:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bee:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bf1:	fc                   	cld    
  800bf2:	f3 ab                	rep stos %eax,%es:(%edi)
  800bf4:	eb 03                	jmp    800bf9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bf6:	fc                   	cld    
  800bf7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bf9:	89 f8                	mov    %edi,%eax
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	8b 45 08             	mov    0x8(%ebp),%eax
  800c08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c0b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c0e:	39 c6                	cmp    %eax,%esi
  800c10:	73 34                	jae    800c46 <memmove+0x46>
  800c12:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c15:	39 d0                	cmp    %edx,%eax
  800c17:	73 2d                	jae    800c46 <memmove+0x46>
		s += n;
		d += n;
  800c19:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c1c:	f6 c2 03             	test   $0x3,%dl
  800c1f:	75 1b                	jne    800c3c <memmove+0x3c>
  800c21:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c27:	75 13                	jne    800c3c <memmove+0x3c>
  800c29:	f6 c1 03             	test   $0x3,%cl
  800c2c:	75 0e                	jne    800c3c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c2e:	83 ef 04             	sub    $0x4,%edi
  800c31:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c34:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c37:	fd                   	std    
  800c38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c3a:	eb 07                	jmp    800c43 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c3c:	4f                   	dec    %edi
  800c3d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c40:	fd                   	std    
  800c41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c43:	fc                   	cld    
  800c44:	eb 20                	jmp    800c66 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c4c:	75 13                	jne    800c61 <memmove+0x61>
  800c4e:	a8 03                	test   $0x3,%al
  800c50:	75 0f                	jne    800c61 <memmove+0x61>
  800c52:	f6 c1 03             	test   $0x3,%cl
  800c55:	75 0a                	jne    800c61 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c57:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c5a:	89 c7                	mov    %eax,%edi
  800c5c:	fc                   	cld    
  800c5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c5f:	eb 05                	jmp    800c66 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c61:	89 c7                	mov    %eax,%edi
  800c63:	fc                   	cld    
  800c64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c70:	8b 45 10             	mov    0x10(%ebp),%eax
  800c73:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c81:	89 04 24             	mov    %eax,(%esp)
  800c84:	e8 77 ff ff ff       	call   800c00 <memmove>
}
  800c89:	c9                   	leave  
  800c8a:	c3                   	ret    

00800c8b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c94:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9f:	eb 16                	jmp    800cb7 <memcmp+0x2c>
		if (*s1 != *s2)
  800ca1:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ca4:	42                   	inc    %edx
  800ca5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ca9:	38 c8                	cmp    %cl,%al
  800cab:	74 0a                	je     800cb7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800cad:	0f b6 c0             	movzbl %al,%eax
  800cb0:	0f b6 c9             	movzbl %cl,%ecx
  800cb3:	29 c8                	sub    %ecx,%eax
  800cb5:	eb 09                	jmp    800cc0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb7:	39 da                	cmp    %ebx,%edx
  800cb9:	75 e6                	jne    800ca1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cce:	89 c2                	mov    %eax,%edx
  800cd0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cd3:	eb 05                	jmp    800cda <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cd5:	38 08                	cmp    %cl,(%eax)
  800cd7:	74 05                	je     800cde <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cd9:	40                   	inc    %eax
  800cda:	39 d0                	cmp    %edx,%eax
  800cdc:	72 f7                	jb     800cd5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cec:	eb 01                	jmp    800cef <strtol+0xf>
		s++;
  800cee:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cef:	8a 02                	mov    (%edx),%al
  800cf1:	3c 20                	cmp    $0x20,%al
  800cf3:	74 f9                	je     800cee <strtol+0xe>
  800cf5:	3c 09                	cmp    $0x9,%al
  800cf7:	74 f5                	je     800cee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cf9:	3c 2b                	cmp    $0x2b,%al
  800cfb:	75 08                	jne    800d05 <strtol+0x25>
		s++;
  800cfd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cfe:	bf 00 00 00 00       	mov    $0x0,%edi
  800d03:	eb 13                	jmp    800d18 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d05:	3c 2d                	cmp    $0x2d,%al
  800d07:	75 0a                	jne    800d13 <strtol+0x33>
		s++, neg = 1;
  800d09:	8d 52 01             	lea    0x1(%edx),%edx
  800d0c:	bf 01 00 00 00       	mov    $0x1,%edi
  800d11:	eb 05                	jmp    800d18 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d13:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d18:	85 db                	test   %ebx,%ebx
  800d1a:	74 05                	je     800d21 <strtol+0x41>
  800d1c:	83 fb 10             	cmp    $0x10,%ebx
  800d1f:	75 28                	jne    800d49 <strtol+0x69>
  800d21:	8a 02                	mov    (%edx),%al
  800d23:	3c 30                	cmp    $0x30,%al
  800d25:	75 10                	jne    800d37 <strtol+0x57>
  800d27:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d2b:	75 0a                	jne    800d37 <strtol+0x57>
		s += 2, base = 16;
  800d2d:	83 c2 02             	add    $0x2,%edx
  800d30:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d35:	eb 12                	jmp    800d49 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d37:	85 db                	test   %ebx,%ebx
  800d39:	75 0e                	jne    800d49 <strtol+0x69>
  800d3b:	3c 30                	cmp    $0x30,%al
  800d3d:	75 05                	jne    800d44 <strtol+0x64>
		s++, base = 8;
  800d3f:	42                   	inc    %edx
  800d40:	b3 08                	mov    $0x8,%bl
  800d42:	eb 05                	jmp    800d49 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d44:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d49:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d50:	8a 0a                	mov    (%edx),%cl
  800d52:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d55:	80 fb 09             	cmp    $0x9,%bl
  800d58:	77 08                	ja     800d62 <strtol+0x82>
			dig = *s - '0';
  800d5a:	0f be c9             	movsbl %cl,%ecx
  800d5d:	83 e9 30             	sub    $0x30,%ecx
  800d60:	eb 1e                	jmp    800d80 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d62:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d65:	80 fb 19             	cmp    $0x19,%bl
  800d68:	77 08                	ja     800d72 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d6a:	0f be c9             	movsbl %cl,%ecx
  800d6d:	83 e9 57             	sub    $0x57,%ecx
  800d70:	eb 0e                	jmp    800d80 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d72:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d75:	80 fb 19             	cmp    $0x19,%bl
  800d78:	77 12                	ja     800d8c <strtol+0xac>
			dig = *s - 'A' + 10;
  800d7a:	0f be c9             	movsbl %cl,%ecx
  800d7d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d80:	39 f1                	cmp    %esi,%ecx
  800d82:	7d 0c                	jge    800d90 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d84:	42                   	inc    %edx
  800d85:	0f af c6             	imul   %esi,%eax
  800d88:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d8a:	eb c4                	jmp    800d50 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d8c:	89 c1                	mov    %eax,%ecx
  800d8e:	eb 02                	jmp    800d92 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d90:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d92:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d96:	74 05                	je     800d9d <strtol+0xbd>
		*endptr = (char *) s;
  800d98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d9b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d9d:	85 ff                	test   %edi,%edi
  800d9f:	74 04                	je     800da5 <strtol+0xc5>
  800da1:	89 c8                	mov    %ecx,%eax
  800da3:	f7 d8                	neg    %eax
}
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    
	...

00800dac <__udivdi3>:
  800dac:	55                   	push   %ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	83 ec 10             	sub    $0x10,%esp
  800db2:	8b 74 24 20          	mov    0x20(%esp),%esi
  800db6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800dba:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dbe:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800dc2:	89 cd                	mov    %ecx,%ebp
  800dc4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	75 2c                	jne    800df8 <__udivdi3+0x4c>
  800dcc:	39 f9                	cmp    %edi,%ecx
  800dce:	77 68                	ja     800e38 <__udivdi3+0x8c>
  800dd0:	85 c9                	test   %ecx,%ecx
  800dd2:	75 0b                	jne    800ddf <__udivdi3+0x33>
  800dd4:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd9:	31 d2                	xor    %edx,%edx
  800ddb:	f7 f1                	div    %ecx
  800ddd:	89 c1                	mov    %eax,%ecx
  800ddf:	31 d2                	xor    %edx,%edx
  800de1:	89 f8                	mov    %edi,%eax
  800de3:	f7 f1                	div    %ecx
  800de5:	89 c7                	mov    %eax,%edi
  800de7:	89 f0                	mov    %esi,%eax
  800de9:	f7 f1                	div    %ecx
  800deb:	89 c6                	mov    %eax,%esi
  800ded:	89 f0                	mov    %esi,%eax
  800def:	89 fa                	mov    %edi,%edx
  800df1:	83 c4 10             	add    $0x10,%esp
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    
  800df8:	39 f8                	cmp    %edi,%eax
  800dfa:	77 2c                	ja     800e28 <__udivdi3+0x7c>
  800dfc:	0f bd f0             	bsr    %eax,%esi
  800dff:	83 f6 1f             	xor    $0x1f,%esi
  800e02:	75 4c                	jne    800e50 <__udivdi3+0xa4>
  800e04:	39 f8                	cmp    %edi,%eax
  800e06:	bf 00 00 00 00       	mov    $0x0,%edi
  800e0b:	72 0a                	jb     800e17 <__udivdi3+0x6b>
  800e0d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e11:	0f 87 ad 00 00 00    	ja     800ec4 <__udivdi3+0x118>
  800e17:	be 01 00 00 00       	mov    $0x1,%esi
  800e1c:	89 f0                	mov    %esi,%eax
  800e1e:	89 fa                	mov    %edi,%edx
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	5e                   	pop    %esi
  800e24:	5f                   	pop    %edi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    
  800e27:	90                   	nop
  800e28:	31 ff                	xor    %edi,%edi
  800e2a:	31 f6                	xor    %esi,%esi
  800e2c:	89 f0                	mov    %esi,%eax
  800e2e:	89 fa                	mov    %edi,%edx
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	5e                   	pop    %esi
  800e34:	5f                   	pop    %edi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    
  800e37:	90                   	nop
  800e38:	89 fa                	mov    %edi,%edx
  800e3a:	89 f0                	mov    %esi,%eax
  800e3c:	f7 f1                	div    %ecx
  800e3e:	89 c6                	mov    %eax,%esi
  800e40:	31 ff                	xor    %edi,%edi
  800e42:	89 f0                	mov    %esi,%eax
  800e44:	89 fa                	mov    %edi,%edx
  800e46:	83 c4 10             	add    $0x10,%esp
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    
  800e4d:	8d 76 00             	lea    0x0(%esi),%esi
  800e50:	89 f1                	mov    %esi,%ecx
  800e52:	d3 e0                	shl    %cl,%eax
  800e54:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e58:	b8 20 00 00 00       	mov    $0x20,%eax
  800e5d:	29 f0                	sub    %esi,%eax
  800e5f:	89 ea                	mov    %ebp,%edx
  800e61:	88 c1                	mov    %al,%cl
  800e63:	d3 ea                	shr    %cl,%edx
  800e65:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e69:	09 ca                	or     %ecx,%edx
  800e6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e6f:	89 f1                	mov    %esi,%ecx
  800e71:	d3 e5                	shl    %cl,%ebp
  800e73:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e77:	89 fd                	mov    %edi,%ebp
  800e79:	88 c1                	mov    %al,%cl
  800e7b:	d3 ed                	shr    %cl,%ebp
  800e7d:	89 fa                	mov    %edi,%edx
  800e7f:	89 f1                	mov    %esi,%ecx
  800e81:	d3 e2                	shl    %cl,%edx
  800e83:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e87:	88 c1                	mov    %al,%cl
  800e89:	d3 ef                	shr    %cl,%edi
  800e8b:	09 d7                	or     %edx,%edi
  800e8d:	89 f8                	mov    %edi,%eax
  800e8f:	89 ea                	mov    %ebp,%edx
  800e91:	f7 74 24 08          	divl   0x8(%esp)
  800e95:	89 d1                	mov    %edx,%ecx
  800e97:	89 c7                	mov    %eax,%edi
  800e99:	f7 64 24 0c          	mull   0xc(%esp)
  800e9d:	39 d1                	cmp    %edx,%ecx
  800e9f:	72 17                	jb     800eb8 <__udivdi3+0x10c>
  800ea1:	74 09                	je     800eac <__udivdi3+0x100>
  800ea3:	89 fe                	mov    %edi,%esi
  800ea5:	31 ff                	xor    %edi,%edi
  800ea7:	e9 41 ff ff ff       	jmp    800ded <__udivdi3+0x41>
  800eac:	8b 54 24 04          	mov    0x4(%esp),%edx
  800eb0:	89 f1                	mov    %esi,%ecx
  800eb2:	d3 e2                	shl    %cl,%edx
  800eb4:	39 c2                	cmp    %eax,%edx
  800eb6:	73 eb                	jae    800ea3 <__udivdi3+0xf7>
  800eb8:	8d 77 ff             	lea    -0x1(%edi),%esi
  800ebb:	31 ff                	xor    %edi,%edi
  800ebd:	e9 2b ff ff ff       	jmp    800ded <__udivdi3+0x41>
  800ec2:	66 90                	xchg   %ax,%ax
  800ec4:	31 f6                	xor    %esi,%esi
  800ec6:	e9 22 ff ff ff       	jmp    800ded <__udivdi3+0x41>
	...

00800ecc <__umoddi3>:
  800ecc:	55                   	push   %ebp
  800ecd:	57                   	push   %edi
  800ece:	56                   	push   %esi
  800ecf:	83 ec 20             	sub    $0x20,%esp
  800ed2:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ed6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800eda:	89 44 24 14          	mov    %eax,0x14(%esp)
  800ede:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ee2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ee6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800eea:	89 c7                	mov    %eax,%edi
  800eec:	89 f2                	mov    %esi,%edx
  800eee:	85 ed                	test   %ebp,%ebp
  800ef0:	75 16                	jne    800f08 <__umoddi3+0x3c>
  800ef2:	39 f1                	cmp    %esi,%ecx
  800ef4:	0f 86 a6 00 00 00    	jbe    800fa0 <__umoddi3+0xd4>
  800efa:	f7 f1                	div    %ecx
  800efc:	89 d0                	mov    %edx,%eax
  800efe:	31 d2                	xor    %edx,%edx
  800f00:	83 c4 20             	add    $0x20,%esp
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    
  800f07:	90                   	nop
  800f08:	39 f5                	cmp    %esi,%ebp
  800f0a:	0f 87 ac 00 00 00    	ja     800fbc <__umoddi3+0xf0>
  800f10:	0f bd c5             	bsr    %ebp,%eax
  800f13:	83 f0 1f             	xor    $0x1f,%eax
  800f16:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1a:	0f 84 a8 00 00 00    	je     800fc8 <__umoddi3+0xfc>
  800f20:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f24:	d3 e5                	shl    %cl,%ebp
  800f26:	bf 20 00 00 00       	mov    $0x20,%edi
  800f2b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800f2f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f33:	89 f9                	mov    %edi,%ecx
  800f35:	d3 e8                	shr    %cl,%eax
  800f37:	09 e8                	or     %ebp,%eax
  800f39:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f3d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f41:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f45:	d3 e0                	shl    %cl,%eax
  800f47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f4b:	89 f2                	mov    %esi,%edx
  800f4d:	d3 e2                	shl    %cl,%edx
  800f4f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f53:	d3 e0                	shl    %cl,%eax
  800f55:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f59:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f5d:	89 f9                	mov    %edi,%ecx
  800f5f:	d3 e8                	shr    %cl,%eax
  800f61:	09 d0                	or     %edx,%eax
  800f63:	d3 ee                	shr    %cl,%esi
  800f65:	89 f2                	mov    %esi,%edx
  800f67:	f7 74 24 18          	divl   0x18(%esp)
  800f6b:	89 d6                	mov    %edx,%esi
  800f6d:	f7 64 24 0c          	mull   0xc(%esp)
  800f71:	89 c5                	mov    %eax,%ebp
  800f73:	89 d1                	mov    %edx,%ecx
  800f75:	39 d6                	cmp    %edx,%esi
  800f77:	72 67                	jb     800fe0 <__umoddi3+0x114>
  800f79:	74 75                	je     800ff0 <__umoddi3+0x124>
  800f7b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f7f:	29 e8                	sub    %ebp,%eax
  800f81:	19 ce                	sbb    %ecx,%esi
  800f83:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f87:	d3 e8                	shr    %cl,%eax
  800f89:	89 f2                	mov    %esi,%edx
  800f8b:	89 f9                	mov    %edi,%ecx
  800f8d:	d3 e2                	shl    %cl,%edx
  800f8f:	09 d0                	or     %edx,%eax
  800f91:	89 f2                	mov    %esi,%edx
  800f93:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f97:	d3 ea                	shr    %cl,%edx
  800f99:	83 c4 20             	add    $0x20,%esp
  800f9c:	5e                   	pop    %esi
  800f9d:	5f                   	pop    %edi
  800f9e:	5d                   	pop    %ebp
  800f9f:	c3                   	ret    
  800fa0:	85 c9                	test   %ecx,%ecx
  800fa2:	75 0b                	jne    800faf <__umoddi3+0xe3>
  800fa4:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa9:	31 d2                	xor    %edx,%edx
  800fab:	f7 f1                	div    %ecx
  800fad:	89 c1                	mov    %eax,%ecx
  800faf:	89 f0                	mov    %esi,%eax
  800fb1:	31 d2                	xor    %edx,%edx
  800fb3:	f7 f1                	div    %ecx
  800fb5:	89 f8                	mov    %edi,%eax
  800fb7:	e9 3e ff ff ff       	jmp    800efa <__umoddi3+0x2e>
  800fbc:	89 f2                	mov    %esi,%edx
  800fbe:	83 c4 20             	add    $0x20,%esp
  800fc1:	5e                   	pop    %esi
  800fc2:	5f                   	pop    %edi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    
  800fc5:	8d 76 00             	lea    0x0(%esi),%esi
  800fc8:	39 f5                	cmp    %esi,%ebp
  800fca:	72 04                	jb     800fd0 <__umoddi3+0x104>
  800fcc:	39 f9                	cmp    %edi,%ecx
  800fce:	77 06                	ja     800fd6 <__umoddi3+0x10a>
  800fd0:	89 f2                	mov    %esi,%edx
  800fd2:	29 cf                	sub    %ecx,%edi
  800fd4:	19 ea                	sbb    %ebp,%edx
  800fd6:	89 f8                	mov    %edi,%eax
  800fd8:	83 c4 20             	add    $0x20,%esp
  800fdb:	5e                   	pop    %esi
  800fdc:	5f                   	pop    %edi
  800fdd:	5d                   	pop    %ebp
  800fde:	c3                   	ret    
  800fdf:	90                   	nop
  800fe0:	89 d1                	mov    %edx,%ecx
  800fe2:	89 c5                	mov    %eax,%ebp
  800fe4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fe8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fec:	eb 8d                	jmp    800f7b <__umoddi3+0xaf>
  800fee:	66 90                	xchg   %ax,%ax
  800ff0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800ff4:	72 ea                	jb     800fe0 <__umoddi3+0x114>
  800ff6:	89 f1                	mov    %esi,%ecx
  800ff8:	eb 81                	jmp    800f7b <__umoddi3+0xaf>

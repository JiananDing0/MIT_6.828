
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	5d                   	pop    %ebp
  80003a:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	56                   	push   %esi
  800040:	53                   	push   %ebx
  800041:	83 ec 10             	sub    $0x10,%esp
  800044:	8b 75 08             	mov    0x8(%ebp),%esi
  800047:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80004a:	e8 ec 00 00 00       	call   80013b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80004f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800054:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80005b:	c1 e0 07             	shl    $0x7,%eax
  80005e:	29 d0                	sub    %edx,%eax
  800060:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800065:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 f6                	test   %esi,%esi
  80006c:	7e 07                	jle    800075 <libmain+0x39>
		binaryname = argv[0];
  80006e:	8b 03                	mov    (%ebx),%eax
  800070:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800075:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800079:	89 34 24             	mov    %esi,(%esp)
  80007c:	e8 b3 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    
  80008d:	00 00                	add    %al,(%eax)
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800096:	e8 30 05 00 00       	call   8005cb <close_all>
	sys_env_destroy(0);
  80009b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    
  8000a9:	00 00                	add    %al,(%eax)
	...

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 28                	jle    800133 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80010f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800126:	00 
  800127:	c7 04 24 27 1f 80 00 	movl   $0x801f27,(%esp)
  80012e:	e8 29 10 00 00       	call   80115c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800133:	83 c4 2c             	add    $0x2c,%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 02 00 00 00       	mov    $0x2,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_yield>:

void
sys_yield(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800182:	be 00 00 00 00       	mov    $0x0,%esi
  800187:	b8 04 00 00 00       	mov    $0x4,%eax
  80018c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800192:	8b 55 08             	mov    0x8(%ebp),%edx
  800195:	89 f7                	mov    %esi,%edi
  800197:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	7e 28                	jle    8001c5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001a8:	00 
  8001a9:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  8001b0:	00 
  8001b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b8:	00 
  8001b9:	c7 04 24 27 1f 80 00 	movl   $0x801f27,(%esp)
  8001c0:	e8 97 0f 00 00       	call   80115c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c5:	83 c4 2c             	add    $0x2c,%esp
  8001c8:	5b                   	pop    %ebx
  8001c9:	5e                   	pop    %esi
  8001ca:	5f                   	pop    %edi
  8001cb:	5d                   	pop    %ebp
  8001cc:	c3                   	ret    

008001cd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	57                   	push   %edi
  8001d1:	56                   	push   %esi
  8001d2:	53                   	push   %ebx
  8001d3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001db:	8b 75 18             	mov    0x18(%ebp),%esi
  8001de:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ec:	85 c0                	test   %eax,%eax
  8001ee:	7e 28                	jle    800218 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001fb:	00 
  8001fc:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  800203:	00 
  800204:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020b:	00 
  80020c:	c7 04 24 27 1f 80 00 	movl   $0x801f27,(%esp)
  800213:	e8 44 0f 00 00       	call   80115c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800218:	83 c4 2c             	add    $0x2c,%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5e                   	pop    %esi
  80021d:	5f                   	pop    %edi
  80021e:	5d                   	pop    %ebp
  80021f:	c3                   	ret    

00800220 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800229:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022e:	b8 06 00 00 00       	mov    $0x6,%eax
  800233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800236:	8b 55 08             	mov    0x8(%ebp),%edx
  800239:	89 df                	mov    %ebx,%edi
  80023b:	89 de                	mov    %ebx,%esi
  80023d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023f:	85 c0                	test   %eax,%eax
  800241:	7e 28                	jle    80026b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800243:	89 44 24 10          	mov    %eax,0x10(%esp)
  800247:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80024e:	00 
  80024f:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  800256:	00 
  800257:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025e:	00 
  80025f:	c7 04 24 27 1f 80 00 	movl   $0x801f27,(%esp)
  800266:	e8 f1 0e 00 00       	call   80115c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026b:	83 c4 2c             	add    $0x2c,%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 08 00 00 00       	mov    $0x8,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 28                	jle    8002be <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a1:	00 
  8002a2:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  8002a9:	00 
  8002aa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b1:	00 
  8002b2:	c7 04 24 27 1f 80 00 	movl   $0x801f27,(%esp)
  8002b9:	e8 9e 0e 00 00       	call   80115c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002be:	83 c4 2c             	add    $0x2c,%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002df:	89 df                	mov    %ebx,%edi
  8002e1:	89 de                	mov    %ebx,%esi
  8002e3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002e5:	85 c0                	test   %eax,%eax
  8002e7:	7e 28                	jle    800311 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ed:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f4:	00 
  8002f5:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  8002fc:	00 
  8002fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800304:	00 
  800305:	c7 04 24 27 1f 80 00 	movl   $0x801f27,(%esp)
  80030c:	e8 4b 0e 00 00       	call   80115c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800311:	83 c4 2c             	add    $0x2c,%esp
  800314:	5b                   	pop    %ebx
  800315:	5e                   	pop    %esi
  800316:	5f                   	pop    %edi
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    

00800319 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
  80031f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800322:	bb 00 00 00 00       	mov    $0x0,%ebx
  800327:	b8 0a 00 00 00       	mov    $0xa,%eax
  80032c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032f:	8b 55 08             	mov    0x8(%ebp),%edx
  800332:	89 df                	mov    %ebx,%edi
  800334:	89 de                	mov    %ebx,%esi
  800336:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 28                	jle    800364 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800340:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800347:	00 
  800348:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  80034f:	00 
  800350:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800357:	00 
  800358:	c7 04 24 27 1f 80 00 	movl   $0x801f27,(%esp)
  80035f:	e8 f8 0d 00 00       	call   80115c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800364:	83 c4 2c             	add    $0x2c,%esp
  800367:	5b                   	pop    %ebx
  800368:	5e                   	pop    %esi
  800369:	5f                   	pop    %edi
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	57                   	push   %edi
  800370:	56                   	push   %esi
  800371:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800372:	be 00 00 00 00       	mov    $0x0,%esi
  800377:	b8 0c 00 00 00       	mov    $0xc,%eax
  80037c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80037f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800382:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800385:	8b 55 08             	mov    0x8(%ebp),%edx
  800388:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5f                   	pop    %edi
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	57                   	push   %edi
  800393:	56                   	push   %esi
  800394:	53                   	push   %ebx
  800395:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800398:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039d:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a5:	89 cb                	mov    %ecx,%ebx
  8003a7:	89 cf                	mov    %ecx,%edi
  8003a9:	89 ce                	mov    %ecx,%esi
  8003ab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003ad:	85 c0                	test   %eax,%eax
  8003af:	7e 28                	jle    8003d9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003b5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003bc:	00 
  8003bd:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  8003c4:	00 
  8003c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003cc:	00 
  8003cd:	c7 04 24 27 1f 80 00 	movl   $0x801f27,(%esp)
  8003d4:	e8 83 0d 00 00       	call   80115c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003d9:	83 c4 2c             	add    $0x2c,%esp
  8003dc:	5b                   	pop    %ebx
  8003dd:	5e                   	pop    %esi
  8003de:	5f                   	pop    %edi
  8003df:	5d                   	pop    %ebp
  8003e0:	c3                   	ret    
  8003e1:	00 00                	add    %al,(%eax)
	...

008003e4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ea:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ef:	c1 e8 0c             	shr    $0xc,%eax
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8003fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fd:	89 04 24             	mov    %eax,(%esp)
  800400:	e8 df ff ff ff       	call   8003e4 <fd2num>
  800405:	05 20 00 0d 00       	add    $0xd0020,%eax
  80040a:	c1 e0 0c             	shl    $0xc,%eax
}
  80040d:	c9                   	leave  
  80040e:	c3                   	ret    

0080040f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	53                   	push   %ebx
  800413:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800416:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80041b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80041d:	89 c2                	mov    %eax,%edx
  80041f:	c1 ea 16             	shr    $0x16,%edx
  800422:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800429:	f6 c2 01             	test   $0x1,%dl
  80042c:	74 11                	je     80043f <fd_alloc+0x30>
  80042e:	89 c2                	mov    %eax,%edx
  800430:	c1 ea 0c             	shr    $0xc,%edx
  800433:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80043a:	f6 c2 01             	test   $0x1,%dl
  80043d:	75 09                	jne    800448 <fd_alloc+0x39>
			*fd_store = fd;
  80043f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800441:	b8 00 00 00 00       	mov    $0x0,%eax
  800446:	eb 17                	jmp    80045f <fd_alloc+0x50>
  800448:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80044d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800452:	75 c7                	jne    80041b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800454:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80045a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80045f:	5b                   	pop    %ebx
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    

00800462 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800468:	83 f8 1f             	cmp    $0x1f,%eax
  80046b:	77 36                	ja     8004a3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80046d:	05 00 00 0d 00       	add    $0xd0000,%eax
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800475:	89 c2                	mov    %eax,%edx
  800477:	c1 ea 16             	shr    $0x16,%edx
  80047a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800481:	f6 c2 01             	test   $0x1,%dl
  800484:	74 24                	je     8004aa <fd_lookup+0x48>
  800486:	89 c2                	mov    %eax,%edx
  800488:	c1 ea 0c             	shr    $0xc,%edx
  80048b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800492:	f6 c2 01             	test   $0x1,%dl
  800495:	74 1a                	je     8004b1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800497:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049a:	89 02                	mov    %eax,(%edx)
	return 0;
  80049c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a1:	eb 13                	jmp    8004b6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004a8:	eb 0c                	jmp    8004b6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004af:	eb 05                	jmp    8004b6 <fd_lookup+0x54>
  8004b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004b6:	5d                   	pop    %ebp
  8004b7:	c3                   	ret    

008004b8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	53                   	push   %ebx
  8004bc:	83 ec 14             	sub    $0x14,%esp
  8004bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8004c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ca:	eb 0e                	jmp    8004da <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8004cc:	39 08                	cmp    %ecx,(%eax)
  8004ce:	75 09                	jne    8004d9 <dev_lookup+0x21>
			*dev = devtab[i];
  8004d0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8004d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d7:	eb 33                	jmp    80050c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004d9:	42                   	inc    %edx
  8004da:	8b 04 95 b4 1f 80 00 	mov    0x801fb4(,%edx,4),%eax
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	75 e7                	jne    8004cc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004e5:	a1 04 40 80 00       	mov    0x804004,%eax
  8004ea:	8b 40 48             	mov    0x48(%eax),%eax
  8004ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f5:	c7 04 24 38 1f 80 00 	movl   $0x801f38,(%esp)
  8004fc:	e8 53 0d 00 00       	call   801254 <cprintf>
	*dev = 0;
  800501:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800507:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80050c:	83 c4 14             	add    $0x14,%esp
  80050f:	5b                   	pop    %ebx
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	56                   	push   %esi
  800516:	53                   	push   %ebx
  800517:	83 ec 30             	sub    $0x30,%esp
  80051a:	8b 75 08             	mov    0x8(%ebp),%esi
  80051d:	8a 45 0c             	mov    0xc(%ebp),%al
  800520:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800523:	89 34 24             	mov    %esi,(%esp)
  800526:	e8 b9 fe ff ff       	call   8003e4 <fd2num>
  80052b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80052e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800532:	89 04 24             	mov    %eax,(%esp)
  800535:	e8 28 ff ff ff       	call   800462 <fd_lookup>
  80053a:	89 c3                	mov    %eax,%ebx
  80053c:	85 c0                	test   %eax,%eax
  80053e:	78 05                	js     800545 <fd_close+0x33>
	    || fd != fd2)
  800540:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800543:	74 0d                	je     800552 <fd_close+0x40>
		return (must_exist ? r : 0);
  800545:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800549:	75 46                	jne    800591 <fd_close+0x7f>
  80054b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800550:	eb 3f                	jmp    800591 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800552:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800555:	89 44 24 04          	mov    %eax,0x4(%esp)
  800559:	8b 06                	mov    (%esi),%eax
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	e8 55 ff ff ff       	call   8004b8 <dev_lookup>
  800563:	89 c3                	mov    %eax,%ebx
  800565:	85 c0                	test   %eax,%eax
  800567:	78 18                	js     800581 <fd_close+0x6f>
		if (dev->dev_close)
  800569:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80056c:	8b 40 10             	mov    0x10(%eax),%eax
  80056f:	85 c0                	test   %eax,%eax
  800571:	74 09                	je     80057c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800573:	89 34 24             	mov    %esi,(%esp)
  800576:	ff d0                	call   *%eax
  800578:	89 c3                	mov    %eax,%ebx
  80057a:	eb 05                	jmp    800581 <fd_close+0x6f>
		else
			r = 0;
  80057c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800581:	89 74 24 04          	mov    %esi,0x4(%esp)
  800585:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80058c:	e8 8f fc ff ff       	call   800220 <sys_page_unmap>
	return r;
}
  800591:	89 d8                	mov    %ebx,%eax
  800593:	83 c4 30             	add    $0x30,%esp
  800596:	5b                   	pop    %ebx
  800597:	5e                   	pop    %esi
  800598:	5d                   	pop    %ebp
  800599:	c3                   	ret    

0080059a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80059a:	55                   	push   %ebp
  80059b:	89 e5                	mov    %esp,%ebp
  80059d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005aa:	89 04 24             	mov    %eax,(%esp)
  8005ad:	e8 b0 fe ff ff       	call   800462 <fd_lookup>
  8005b2:	85 c0                	test   %eax,%eax
  8005b4:	78 13                	js     8005c9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8005b6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005bd:	00 
  8005be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005c1:	89 04 24             	mov    %eax,(%esp)
  8005c4:	e8 49 ff ff ff       	call   800512 <fd_close>
}
  8005c9:	c9                   	leave  
  8005ca:	c3                   	ret    

008005cb <close_all>:

void
close_all(void)
{
  8005cb:	55                   	push   %ebp
  8005cc:	89 e5                	mov    %esp,%ebp
  8005ce:	53                   	push   %ebx
  8005cf:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005d2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005d7:	89 1c 24             	mov    %ebx,(%esp)
  8005da:	e8 bb ff ff ff       	call   80059a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005df:	43                   	inc    %ebx
  8005e0:	83 fb 20             	cmp    $0x20,%ebx
  8005e3:	75 f2                	jne    8005d7 <close_all+0xc>
		close(i);
}
  8005e5:	83 c4 14             	add    $0x14,%esp
  8005e8:	5b                   	pop    %ebx
  8005e9:	5d                   	pop    %ebp
  8005ea:	c3                   	ret    

008005eb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005eb:	55                   	push   %ebp
  8005ec:	89 e5                	mov    %esp,%ebp
  8005ee:	57                   	push   %edi
  8005ef:	56                   	push   %esi
  8005f0:	53                   	push   %ebx
  8005f1:	83 ec 4c             	sub    $0x4c,%esp
  8005f4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005f7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800601:	89 04 24             	mov    %eax,(%esp)
  800604:	e8 59 fe ff ff       	call   800462 <fd_lookup>
  800609:	89 c3                	mov    %eax,%ebx
  80060b:	85 c0                	test   %eax,%eax
  80060d:	0f 88 e1 00 00 00    	js     8006f4 <dup+0x109>
		return r;
	close(newfdnum);
  800613:	89 3c 24             	mov    %edi,(%esp)
  800616:	e8 7f ff ff ff       	call   80059a <close>

	newfd = INDEX2FD(newfdnum);
  80061b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800621:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800624:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800627:	89 04 24             	mov    %eax,(%esp)
  80062a:	e8 c5 fd ff ff       	call   8003f4 <fd2data>
  80062f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800631:	89 34 24             	mov    %esi,(%esp)
  800634:	e8 bb fd ff ff       	call   8003f4 <fd2data>
  800639:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80063c:	89 d8                	mov    %ebx,%eax
  80063e:	c1 e8 16             	shr    $0x16,%eax
  800641:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800648:	a8 01                	test   $0x1,%al
  80064a:	74 46                	je     800692 <dup+0xa7>
  80064c:	89 d8                	mov    %ebx,%eax
  80064e:	c1 e8 0c             	shr    $0xc,%eax
  800651:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800658:	f6 c2 01             	test   $0x1,%dl
  80065b:	74 35                	je     800692 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80065d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800664:	25 07 0e 00 00       	and    $0xe07,%eax
  800669:	89 44 24 10          	mov    %eax,0x10(%esp)
  80066d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800670:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800674:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80067b:	00 
  80067c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800680:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800687:	e8 41 fb ff ff       	call   8001cd <sys_page_map>
  80068c:	89 c3                	mov    %eax,%ebx
  80068e:	85 c0                	test   %eax,%eax
  800690:	78 3b                	js     8006cd <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800692:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800695:	89 c2                	mov    %eax,%edx
  800697:	c1 ea 0c             	shr    $0xc,%edx
  80069a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006a1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006a7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006ab:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006b6:	00 
  8006b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006c2:	e8 06 fb ff ff       	call   8001cd <sys_page_map>
  8006c7:	89 c3                	mov    %eax,%ebx
  8006c9:	85 c0                	test   %eax,%eax
  8006cb:	79 25                	jns    8006f2 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006d8:	e8 43 fb ff ff       	call   800220 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006eb:	e8 30 fb ff ff       	call   800220 <sys_page_unmap>
	return r;
  8006f0:	eb 02                	jmp    8006f4 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8006f2:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8006f4:	89 d8                	mov    %ebx,%eax
  8006f6:	83 c4 4c             	add    $0x4c,%esp
  8006f9:	5b                   	pop    %ebx
  8006fa:	5e                   	pop    %esi
  8006fb:	5f                   	pop    %edi
  8006fc:	5d                   	pop    %ebp
  8006fd:	c3                   	ret    

008006fe <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	53                   	push   %ebx
  800702:	83 ec 24             	sub    $0x24,%esp
  800705:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800708:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070f:	89 1c 24             	mov    %ebx,(%esp)
  800712:	e8 4b fd ff ff       	call   800462 <fd_lookup>
  800717:	85 c0                	test   %eax,%eax
  800719:	78 6d                	js     800788 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800722:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800725:	8b 00                	mov    (%eax),%eax
  800727:	89 04 24             	mov    %eax,(%esp)
  80072a:	e8 89 fd ff ff       	call   8004b8 <dev_lookup>
  80072f:	85 c0                	test   %eax,%eax
  800731:	78 55                	js     800788 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800733:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800736:	8b 50 08             	mov    0x8(%eax),%edx
  800739:	83 e2 03             	and    $0x3,%edx
  80073c:	83 fa 01             	cmp    $0x1,%edx
  80073f:	75 23                	jne    800764 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800741:	a1 04 40 80 00       	mov    0x804004,%eax
  800746:	8b 40 48             	mov    0x48(%eax),%eax
  800749:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80074d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800751:	c7 04 24 79 1f 80 00 	movl   $0x801f79,(%esp)
  800758:	e8 f7 0a 00 00       	call   801254 <cprintf>
		return -E_INVAL;
  80075d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800762:	eb 24                	jmp    800788 <read+0x8a>
	}
	if (!dev->dev_read)
  800764:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800767:	8b 52 08             	mov    0x8(%edx),%edx
  80076a:	85 d2                	test   %edx,%edx
  80076c:	74 15                	je     800783 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80076e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800771:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800775:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800778:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80077c:	89 04 24             	mov    %eax,(%esp)
  80077f:	ff d2                	call   *%edx
  800781:	eb 05                	jmp    800788 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800783:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800788:	83 c4 24             	add    $0x24,%esp
  80078b:	5b                   	pop    %ebx
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	57                   	push   %edi
  800792:	56                   	push   %esi
  800793:	53                   	push   %ebx
  800794:	83 ec 1c             	sub    $0x1c,%esp
  800797:	8b 7d 08             	mov    0x8(%ebp),%edi
  80079a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80079d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007a2:	eb 23                	jmp    8007c7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007a4:	89 f0                	mov    %esi,%eax
  8007a6:	29 d8                	sub    %ebx,%eax
  8007a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007af:	01 d8                	add    %ebx,%eax
  8007b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b5:	89 3c 24             	mov    %edi,(%esp)
  8007b8:	e8 41 ff ff ff       	call   8006fe <read>
		if (m < 0)
  8007bd:	85 c0                	test   %eax,%eax
  8007bf:	78 10                	js     8007d1 <readn+0x43>
			return m;
		if (m == 0)
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	74 0a                	je     8007cf <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007c5:	01 c3                	add    %eax,%ebx
  8007c7:	39 f3                	cmp    %esi,%ebx
  8007c9:	72 d9                	jb     8007a4 <readn+0x16>
  8007cb:	89 d8                	mov    %ebx,%eax
  8007cd:	eb 02                	jmp    8007d1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8007cf:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007d1:	83 c4 1c             	add    $0x1c,%esp
  8007d4:	5b                   	pop    %ebx
  8007d5:	5e                   	pop    %esi
  8007d6:	5f                   	pop    %edi
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	53                   	push   %ebx
  8007dd:	83 ec 24             	sub    $0x24,%esp
  8007e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ea:	89 1c 24             	mov    %ebx,(%esp)
  8007ed:	e8 70 fc ff ff       	call   800462 <fd_lookup>
  8007f2:	85 c0                	test   %eax,%eax
  8007f4:	78 68                	js     80085e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800800:	8b 00                	mov    (%eax),%eax
  800802:	89 04 24             	mov    %eax,(%esp)
  800805:	e8 ae fc ff ff       	call   8004b8 <dev_lookup>
  80080a:	85 c0                	test   %eax,%eax
  80080c:	78 50                	js     80085e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80080e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800811:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800815:	75 23                	jne    80083a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800817:	a1 04 40 80 00       	mov    0x804004,%eax
  80081c:	8b 40 48             	mov    0x48(%eax),%eax
  80081f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800823:	89 44 24 04          	mov    %eax,0x4(%esp)
  800827:	c7 04 24 95 1f 80 00 	movl   $0x801f95,(%esp)
  80082e:	e8 21 0a 00 00       	call   801254 <cprintf>
		return -E_INVAL;
  800833:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800838:	eb 24                	jmp    80085e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80083a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083d:	8b 52 0c             	mov    0xc(%edx),%edx
  800840:	85 d2                	test   %edx,%edx
  800842:	74 15                	je     800859 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800844:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800847:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80084b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800852:	89 04 24             	mov    %eax,(%esp)
  800855:	ff d2                	call   *%edx
  800857:	eb 05                	jmp    80085e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800859:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80085e:	83 c4 24             	add    $0x24,%esp
  800861:	5b                   	pop    %ebx
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <seek>:

int
seek(int fdnum, off_t offset)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80086a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80086d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	89 04 24             	mov    %eax,(%esp)
  800877:	e8 e6 fb ff ff       	call   800462 <fd_lookup>
  80087c:	85 c0                	test   %eax,%eax
  80087e:	78 0e                	js     80088e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800880:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800883:	8b 55 0c             	mov    0xc(%ebp),%edx
  800886:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800889:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    

00800890 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	53                   	push   %ebx
  800894:	83 ec 24             	sub    $0x24,%esp
  800897:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80089a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80089d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a1:	89 1c 24             	mov    %ebx,(%esp)
  8008a4:	e8 b9 fb ff ff       	call   800462 <fd_lookup>
  8008a9:	85 c0                	test   %eax,%eax
  8008ab:	78 61                	js     80090e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b7:	8b 00                	mov    (%eax),%eax
  8008b9:	89 04 24             	mov    %eax,(%esp)
  8008bc:	e8 f7 fb ff ff       	call   8004b8 <dev_lookup>
  8008c1:	85 c0                	test   %eax,%eax
  8008c3:	78 49                	js     80090e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008cc:	75 23                	jne    8008f1 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008ce:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008d3:	8b 40 48             	mov    0x48(%eax),%eax
  8008d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008de:	c7 04 24 58 1f 80 00 	movl   $0x801f58,(%esp)
  8008e5:	e8 6a 09 00 00       	call   801254 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ef:	eb 1d                	jmp    80090e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8008f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008f4:	8b 52 18             	mov    0x18(%edx),%edx
  8008f7:	85 d2                	test   %edx,%edx
  8008f9:	74 0e                	je     800909 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800902:	89 04 24             	mov    %eax,(%esp)
  800905:	ff d2                	call   *%edx
  800907:	eb 05                	jmp    80090e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800909:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80090e:	83 c4 24             	add    $0x24,%esp
  800911:	5b                   	pop    %ebx
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	53                   	push   %ebx
  800918:	83 ec 24             	sub    $0x24,%esp
  80091b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80091e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800921:	89 44 24 04          	mov    %eax,0x4(%esp)
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	89 04 24             	mov    %eax,(%esp)
  80092b:	e8 32 fb ff ff       	call   800462 <fd_lookup>
  800930:	85 c0                	test   %eax,%eax
  800932:	78 52                	js     800986 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800934:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800937:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80093e:	8b 00                	mov    (%eax),%eax
  800940:	89 04 24             	mov    %eax,(%esp)
  800943:	e8 70 fb ff ff       	call   8004b8 <dev_lookup>
  800948:	85 c0                	test   %eax,%eax
  80094a:	78 3a                	js     800986 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80094c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800953:	74 2c                	je     800981 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800955:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800958:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80095f:	00 00 00 
	stat->st_isdir = 0;
  800962:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800969:	00 00 00 
	stat->st_dev = dev;
  80096c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800972:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800976:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800979:	89 14 24             	mov    %edx,(%esp)
  80097c:	ff 50 14             	call   *0x14(%eax)
  80097f:	eb 05                	jmp    800986 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800981:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800986:	83 c4 24             	add    $0x24,%esp
  800989:	5b                   	pop    %ebx
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	56                   	push   %esi
  800990:	53                   	push   %ebx
  800991:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800994:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80099b:	00 
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	89 04 24             	mov    %eax,(%esp)
  8009a2:	e8 fe 01 00 00       	call   800ba5 <open>
  8009a7:	89 c3                	mov    %eax,%ebx
  8009a9:	85 c0                	test   %eax,%eax
  8009ab:	78 1b                	js     8009c8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b4:	89 1c 24             	mov    %ebx,(%esp)
  8009b7:	e8 58 ff ff ff       	call   800914 <fstat>
  8009bc:	89 c6                	mov    %eax,%esi
	close(fd);
  8009be:	89 1c 24             	mov    %ebx,(%esp)
  8009c1:	e8 d4 fb ff ff       	call   80059a <close>
	return r;
  8009c6:	89 f3                	mov    %esi,%ebx
}
  8009c8:	89 d8                	mov    %ebx,%eax
  8009ca:	83 c4 10             	add    $0x10,%esp
  8009cd:	5b                   	pop    %ebx
  8009ce:	5e                   	pop    %esi
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    
  8009d1:	00 00                	add    %al,(%eax)
	...

008009d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	56                   	push   %esi
  8009d8:	53                   	push   %ebx
  8009d9:	83 ec 10             	sub    $0x10,%esp
  8009dc:	89 c3                	mov    %eax,%ebx
  8009de:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8009e0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009e7:	75 11                	jne    8009fa <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009f0:	e8 20 12 00 00       	call   801c15 <ipc_find_env>
  8009f5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009fa:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a01:	00 
  800a02:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a09:	00 
  800a0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0e:	a1 00 40 80 00       	mov    0x804000,%eax
  800a13:	89 04 24             	mov    %eax,(%esp)
  800a16:	e8 90 11 00 00       	call   801bab <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a22:	00 
  800a23:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a2e:	e8 11 11 00 00       	call   801b44 <ipc_recv>
}
  800a33:	83 c4 10             	add    $0x10,%esp
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	8b 40 0c             	mov    0xc(%eax),%eax
  800a46:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a53:	ba 00 00 00 00       	mov    $0x0,%edx
  800a58:	b8 02 00 00 00       	mov    $0x2,%eax
  800a5d:	e8 72 ff ff ff       	call   8009d4 <fsipc>
}
  800a62:	c9                   	leave  
  800a63:	c3                   	ret    

00800a64 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a70:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a75:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7a:	b8 06 00 00 00       	mov    $0x6,%eax
  800a7f:	e8 50 ff ff ff       	call   8009d4 <fsipc>
}
  800a84:	c9                   	leave  
  800a85:	c3                   	ret    

00800a86 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	53                   	push   %ebx
  800a8a:	83 ec 14             	sub    $0x14,%esp
  800a8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	8b 40 0c             	mov    0xc(%eax),%eax
  800a96:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa0:	b8 05 00 00 00       	mov    $0x5,%eax
  800aa5:	e8 2a ff ff ff       	call   8009d4 <fsipc>
  800aaa:	85 c0                	test   %eax,%eax
  800aac:	78 2b                	js     800ad9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800aae:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ab5:	00 
  800ab6:	89 1c 24             	mov    %ebx,(%esp)
  800ab9:	e8 61 0d 00 00       	call   80181f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800abe:	a1 80 50 80 00       	mov    0x805080,%eax
  800ac3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ac9:	a1 84 50 80 00       	mov    0x805084,%eax
  800ace:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ad4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad9:	83 c4 14             	add    $0x14,%esp
  800adc:	5b                   	pop    %ebx
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800ae5:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  800aec:	00 
  800aed:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800af4:	00 
  800af5:	c7 04 24 e2 1f 80 00 	movl   $0x801fe2,(%esp)
  800afc:	e8 5b 06 00 00       	call   80115c <_panic>

00800b01 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	83 ec 10             	sub    $0x10,%esp
  800b09:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0f:	8b 40 0c             	mov    0xc(%eax),%eax
  800b12:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b17:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b22:	b8 03 00 00 00       	mov    $0x3,%eax
  800b27:	e8 a8 fe ff ff       	call   8009d4 <fsipc>
  800b2c:	89 c3                	mov    %eax,%ebx
  800b2e:	85 c0                	test   %eax,%eax
  800b30:	78 6a                	js     800b9c <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800b32:	39 c6                	cmp    %eax,%esi
  800b34:	73 24                	jae    800b5a <devfile_read+0x59>
  800b36:	c7 44 24 0c ed 1f 80 	movl   $0x801fed,0xc(%esp)
  800b3d:	00 
  800b3e:	c7 44 24 08 f4 1f 80 	movl   $0x801ff4,0x8(%esp)
  800b45:	00 
  800b46:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800b4d:	00 
  800b4e:	c7 04 24 e2 1f 80 00 	movl   $0x801fe2,(%esp)
  800b55:	e8 02 06 00 00       	call   80115c <_panic>
	assert(r <= PGSIZE);
  800b5a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b5f:	7e 24                	jle    800b85 <devfile_read+0x84>
  800b61:	c7 44 24 0c 09 20 80 	movl   $0x802009,0xc(%esp)
  800b68:	00 
  800b69:	c7 44 24 08 f4 1f 80 	movl   $0x801ff4,0x8(%esp)
  800b70:	00 
  800b71:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800b78:	00 
  800b79:	c7 04 24 e2 1f 80 00 	movl   $0x801fe2,(%esp)
  800b80:	e8 d7 05 00 00       	call   80115c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b85:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b89:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b90:	00 
  800b91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b94:	89 04 24             	mov    %eax,(%esp)
  800b97:	e8 fc 0d 00 00       	call   801998 <memmove>
	return r;
}
  800b9c:	89 d8                	mov    %ebx,%eax
  800b9e:	83 c4 10             	add    $0x10,%esp
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
  800baa:	83 ec 20             	sub    $0x20,%esp
  800bad:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800bb0:	89 34 24             	mov    %esi,(%esp)
  800bb3:	e8 34 0c 00 00       	call   8017ec <strlen>
  800bb8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800bbd:	7f 60                	jg     800c1f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bbf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bc2:	89 04 24             	mov    %eax,(%esp)
  800bc5:	e8 45 f8 ff ff       	call   80040f <fd_alloc>
  800bca:	89 c3                	mov    %eax,%ebx
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	78 54                	js     800c24 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800bd0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bd4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800bdb:	e8 3f 0c 00 00       	call   80181f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800be0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800be8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800beb:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf0:	e8 df fd ff ff       	call   8009d4 <fsipc>
  800bf5:	89 c3                	mov    %eax,%ebx
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	79 15                	jns    800c10 <open+0x6b>
		fd_close(fd, 0);
  800bfb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c02:	00 
  800c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c06:	89 04 24             	mov    %eax,(%esp)
  800c09:	e8 04 f9 ff ff       	call   800512 <fd_close>
		return r;
  800c0e:	eb 14                	jmp    800c24 <open+0x7f>
	}

	return fd2num(fd);
  800c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c13:	89 04 24             	mov    %eax,(%esp)
  800c16:	e8 c9 f7 ff ff       	call   8003e4 <fd2num>
  800c1b:	89 c3                	mov    %eax,%ebx
  800c1d:	eb 05                	jmp    800c24 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c1f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c24:	89 d8                	mov    %ebx,%eax
  800c26:	83 c4 20             	add    $0x20,%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c33:	ba 00 00 00 00       	mov    $0x0,%edx
  800c38:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3d:	e8 92 fd ff ff       	call   8009d4 <fsipc>
}
  800c42:	c9                   	leave  
  800c43:	c3                   	ret    

00800c44 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 10             	sub    $0x10,%esp
  800c4c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c52:	89 04 24             	mov    %eax,(%esp)
  800c55:	e8 9a f7 ff ff       	call   8003f4 <fd2data>
  800c5a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800c5c:	c7 44 24 04 15 20 80 	movl   $0x802015,0x4(%esp)
  800c63:	00 
  800c64:	89 34 24             	mov    %esi,(%esp)
  800c67:	e8 b3 0b 00 00       	call   80181f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c6c:	8b 43 04             	mov    0x4(%ebx),%eax
  800c6f:	2b 03                	sub    (%ebx),%eax
  800c71:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800c77:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800c7e:	00 00 00 
	stat->st_dev = &devpipe;
  800c81:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800c88:	30 80 00 
	return 0;
}
  800c8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c90:	83 c4 10             	add    $0x10,%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	53                   	push   %ebx
  800c9b:	83 ec 14             	sub    $0x14,%esp
  800c9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ca1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ca5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cac:	e8 6f f5 ff ff       	call   800220 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800cb1:	89 1c 24             	mov    %ebx,(%esp)
  800cb4:	e8 3b f7 ff ff       	call   8003f4 <fd2data>
  800cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cc4:	e8 57 f5 ff ff       	call   800220 <sys_page_unmap>
}
  800cc9:	83 c4 14             	add    $0x14,%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 2c             	sub    $0x2c,%esp
  800cd8:	89 c7                	mov    %eax,%edi
  800cda:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800cdd:	a1 04 40 80 00       	mov    0x804004,%eax
  800ce2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800ce5:	89 3c 24             	mov    %edi,(%esp)
  800ce8:	e8 6f 0f 00 00       	call   801c5c <pageref>
  800ced:	89 c6                	mov    %eax,%esi
  800cef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cf2:	89 04 24             	mov    %eax,(%esp)
  800cf5:	e8 62 0f 00 00       	call   801c5c <pageref>
  800cfa:	39 c6                	cmp    %eax,%esi
  800cfc:	0f 94 c0             	sete   %al
  800cff:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800d02:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800d08:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800d0b:	39 cb                	cmp    %ecx,%ebx
  800d0d:	75 08                	jne    800d17 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800d0f:	83 c4 2c             	add    $0x2c,%esp
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800d17:	83 f8 01             	cmp    $0x1,%eax
  800d1a:	75 c1                	jne    800cdd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800d1c:	8b 42 58             	mov    0x58(%edx),%eax
  800d1f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800d26:	00 
  800d27:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d2b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d2f:	c7 04 24 1c 20 80 00 	movl   $0x80201c,(%esp)
  800d36:	e8 19 05 00 00       	call   801254 <cprintf>
  800d3b:	eb a0                	jmp    800cdd <_pipeisclosed+0xe>

00800d3d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 1c             	sub    $0x1c,%esp
  800d46:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800d49:	89 34 24             	mov    %esi,(%esp)
  800d4c:	e8 a3 f6 ff ff       	call   8003f4 <fd2data>
  800d51:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d53:	bf 00 00 00 00       	mov    $0x0,%edi
  800d58:	eb 3c                	jmp    800d96 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800d5a:	89 da                	mov    %ebx,%edx
  800d5c:	89 f0                	mov    %esi,%eax
  800d5e:	e8 6c ff ff ff       	call   800ccf <_pipeisclosed>
  800d63:	85 c0                	test   %eax,%eax
  800d65:	75 38                	jne    800d9f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800d67:	e8 ee f3 ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d6c:	8b 43 04             	mov    0x4(%ebx),%eax
  800d6f:	8b 13                	mov    (%ebx),%edx
  800d71:	83 c2 20             	add    $0x20,%edx
  800d74:	39 d0                	cmp    %edx,%eax
  800d76:	73 e2                	jae    800d5a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d78:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d7b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800d7e:	89 c2                	mov    %eax,%edx
  800d80:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800d86:	79 05                	jns    800d8d <devpipe_write+0x50>
  800d88:	4a                   	dec    %edx
  800d89:	83 ca e0             	or     $0xffffffe0,%edx
  800d8c:	42                   	inc    %edx
  800d8d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d91:	40                   	inc    %eax
  800d92:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d95:	47                   	inc    %edi
  800d96:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d99:	75 d1                	jne    800d6c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800d9b:	89 f8                	mov    %edi,%eax
  800d9d:	eb 05                	jmp    800da4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d9f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800da4:	83 c4 1c             	add    $0x1c,%esp
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
  800db2:	83 ec 1c             	sub    $0x1c,%esp
  800db5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800db8:	89 3c 24             	mov    %edi,(%esp)
  800dbb:	e8 34 f6 ff ff       	call   8003f4 <fd2data>
  800dc0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800dc2:	be 00 00 00 00       	mov    $0x0,%esi
  800dc7:	eb 3a                	jmp    800e03 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800dc9:	85 f6                	test   %esi,%esi
  800dcb:	74 04                	je     800dd1 <devpipe_read+0x25>
				return i;
  800dcd:	89 f0                	mov    %esi,%eax
  800dcf:	eb 40                	jmp    800e11 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800dd1:	89 da                	mov    %ebx,%edx
  800dd3:	89 f8                	mov    %edi,%eax
  800dd5:	e8 f5 fe ff ff       	call   800ccf <_pipeisclosed>
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	75 2e                	jne    800e0c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800dde:	e8 77 f3 ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800de3:	8b 03                	mov    (%ebx),%eax
  800de5:	3b 43 04             	cmp    0x4(%ebx),%eax
  800de8:	74 df                	je     800dc9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800dea:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800def:	79 05                	jns    800df6 <devpipe_read+0x4a>
  800df1:	48                   	dec    %eax
  800df2:	83 c8 e0             	or     $0xffffffe0,%eax
  800df5:	40                   	inc    %eax
  800df6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800dfa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dfd:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800e00:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e02:	46                   	inc    %esi
  800e03:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e06:	75 db                	jne    800de3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800e08:	89 f0                	mov    %esi,%eax
  800e0a:	eb 05                	jmp    800e11 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e0c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800e11:	83 c4 1c             	add    $0x1c,%esp
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	83 ec 3c             	sub    $0x3c,%esp
  800e22:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800e25:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e28:	89 04 24             	mov    %eax,(%esp)
  800e2b:	e8 df f5 ff ff       	call   80040f <fd_alloc>
  800e30:	89 c3                	mov    %eax,%ebx
  800e32:	85 c0                	test   %eax,%eax
  800e34:	0f 88 45 01 00 00    	js     800f7f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e3a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e41:	00 
  800e42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e50:	e8 24 f3 ff ff       	call   800179 <sys_page_alloc>
  800e55:	89 c3                	mov    %eax,%ebx
  800e57:	85 c0                	test   %eax,%eax
  800e59:	0f 88 20 01 00 00    	js     800f7f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800e5f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800e62:	89 04 24             	mov    %eax,(%esp)
  800e65:	e8 a5 f5 ff ff       	call   80040f <fd_alloc>
  800e6a:	89 c3                	mov    %eax,%ebx
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	0f 88 f8 00 00 00    	js     800f6c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e74:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e7b:	00 
  800e7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e8a:	e8 ea f2 ff ff       	call   800179 <sys_page_alloc>
  800e8f:	89 c3                	mov    %eax,%ebx
  800e91:	85 c0                	test   %eax,%eax
  800e93:	0f 88 d3 00 00 00    	js     800f6c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800e99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e9c:	89 04 24             	mov    %eax,(%esp)
  800e9f:	e8 50 f5 ff ff       	call   8003f4 <fd2data>
  800ea4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ea6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ead:	00 
  800eae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eb2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eb9:	e8 bb f2 ff ff       	call   800179 <sys_page_alloc>
  800ebe:	89 c3                	mov    %eax,%ebx
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	0f 88 91 00 00 00    	js     800f59 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ec8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ecb:	89 04 24             	mov    %eax,(%esp)
  800ece:	e8 21 f5 ff ff       	call   8003f4 <fd2data>
  800ed3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800eda:	00 
  800edb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800edf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ee6:	00 
  800ee7:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eeb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ef2:	e8 d6 f2 ff ff       	call   8001cd <sys_page_map>
  800ef7:	89 c3                	mov    %eax,%ebx
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	78 4c                	js     800f49 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800efd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f06:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800f08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f0b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800f12:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f18:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f1b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800f1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f20:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800f27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f2a:	89 04 24             	mov    %eax,(%esp)
  800f2d:	e8 b2 f4 ff ff       	call   8003e4 <fd2num>
  800f32:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800f34:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f37:	89 04 24             	mov    %eax,(%esp)
  800f3a:	e8 a5 f4 ff ff       	call   8003e4 <fd2num>
  800f3f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800f42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f47:	eb 36                	jmp    800f7f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  800f49:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f54:	e8 c7 f2 ff ff       	call   800220 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  800f59:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f67:	e8 b4 f2 ff ff       	call   800220 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  800f6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f7a:	e8 a1 f2 ff ff       	call   800220 <sys_page_unmap>
    err:
	return r;
}
  800f7f:	89 d8                	mov    %ebx,%eax
  800f81:	83 c4 3c             	add    $0x3c,%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f92:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f96:	8b 45 08             	mov    0x8(%ebp),%eax
  800f99:	89 04 24             	mov    %eax,(%esp)
  800f9c:	e8 c1 f4 ff ff       	call   800462 <fd_lookup>
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	78 15                	js     800fba <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa8:	89 04 24             	mov    %eax,(%esp)
  800fab:	e8 44 f4 ff ff       	call   8003f4 <fd2data>
	return _pipeisclosed(fd, p);
  800fb0:	89 c2                	mov    %eax,%edx
  800fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb5:	e8 15 fd ff ff       	call   800ccf <_pipeisclosed>
}
  800fba:	c9                   	leave  
  800fbb:	c3                   	ret    

00800fbc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800fbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800fcc:	c7 44 24 04 34 20 80 	movl   $0x802034,0x4(%esp)
  800fd3:	00 
  800fd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd7:	89 04 24             	mov    %eax,(%esp)
  800fda:	e8 40 08 00 00       	call   80181f <strcpy>
	return 0;
}
  800fdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe4:	c9                   	leave  
  800fe5:	c3                   	ret    

00800fe6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	57                   	push   %edi
  800fea:	56                   	push   %esi
  800feb:	53                   	push   %ebx
  800fec:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ff2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ff7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ffd:	eb 30                	jmp    80102f <devcons_write+0x49>
		m = n - tot;
  800fff:	8b 75 10             	mov    0x10(%ebp),%esi
  801002:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801004:	83 fe 7f             	cmp    $0x7f,%esi
  801007:	76 05                	jbe    80100e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801009:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80100e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801012:	03 45 0c             	add    0xc(%ebp),%eax
  801015:	89 44 24 04          	mov    %eax,0x4(%esp)
  801019:	89 3c 24             	mov    %edi,(%esp)
  80101c:	e8 77 09 00 00       	call   801998 <memmove>
		sys_cputs(buf, m);
  801021:	89 74 24 04          	mov    %esi,0x4(%esp)
  801025:	89 3c 24             	mov    %edi,(%esp)
  801028:	e8 7f f0 ff ff       	call   8000ac <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80102d:	01 f3                	add    %esi,%ebx
  80102f:	89 d8                	mov    %ebx,%eax
  801031:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801034:	72 c9                	jb     800fff <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801036:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80103c:	5b                   	pop    %ebx
  80103d:	5e                   	pop    %esi
  80103e:	5f                   	pop    %edi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    

00801041 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801047:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80104b:	75 07                	jne    801054 <devcons_read+0x13>
  80104d:	eb 25                	jmp    801074 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80104f:	e8 06 f1 ff ff       	call   80015a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801054:	e8 71 f0 ff ff       	call   8000ca <sys_cgetc>
  801059:	85 c0                	test   %eax,%eax
  80105b:	74 f2                	je     80104f <devcons_read+0xe>
  80105d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80105f:	85 c0                	test   %eax,%eax
  801061:	78 1d                	js     801080 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801063:	83 f8 04             	cmp    $0x4,%eax
  801066:	74 13                	je     80107b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801068:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106b:	88 10                	mov    %dl,(%eax)
	return 1;
  80106d:	b8 01 00 00 00       	mov    $0x1,%eax
  801072:	eb 0c                	jmp    801080 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801074:	b8 00 00 00 00       	mov    $0x0,%eax
  801079:	eb 05                	jmp    801080 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80107b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801080:	c9                   	leave  
  801081:	c3                   	ret    

00801082 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801088:	8b 45 08             	mov    0x8(%ebp),%eax
  80108b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80108e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801095:	00 
  801096:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801099:	89 04 24             	mov    %eax,(%esp)
  80109c:	e8 0b f0 ff ff       	call   8000ac <sys_cputs>
}
  8010a1:	c9                   	leave  
  8010a2:	c3                   	ret    

008010a3 <getchar>:

int
getchar(void)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8010a9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010b0:	00 
  8010b1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010bf:	e8 3a f6 ff ff       	call   8006fe <read>
	if (r < 0)
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	78 0f                	js     8010d7 <getchar+0x34>
		return r;
	if (r < 1)
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	7e 06                	jle    8010d2 <getchar+0x2f>
		return -E_EOF;
	return c;
  8010cc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8010d0:	eb 05                	jmp    8010d7 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8010d2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8010d7:	c9                   	leave  
  8010d8:	c3                   	ret    

008010d9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	89 04 24             	mov    %eax,(%esp)
  8010ec:	e8 71 f3 ff ff       	call   800462 <fd_lookup>
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	78 11                	js     801106 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8010f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010f8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010fe:	39 10                	cmp    %edx,(%eax)
  801100:	0f 94 c0             	sete   %al
  801103:	0f b6 c0             	movzbl %al,%eax
}
  801106:	c9                   	leave  
  801107:	c3                   	ret    

00801108 <opencons>:

int
opencons(void)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80110e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801111:	89 04 24             	mov    %eax,(%esp)
  801114:	e8 f6 f2 ff ff       	call   80040f <fd_alloc>
  801119:	85 c0                	test   %eax,%eax
  80111b:	78 3c                	js     801159 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80111d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801124:	00 
  801125:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801128:	89 44 24 04          	mov    %eax,0x4(%esp)
  80112c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801133:	e8 41 f0 ff ff       	call   800179 <sys_page_alloc>
  801138:	85 c0                	test   %eax,%eax
  80113a:	78 1d                	js     801159 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80113c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801142:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801145:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801147:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801151:	89 04 24             	mov    %eax,(%esp)
  801154:	e8 8b f2 ff ff       	call   8003e4 <fd2num>
}
  801159:	c9                   	leave  
  80115a:	c3                   	ret    
	...

0080115c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	56                   	push   %esi
  801160:	53                   	push   %ebx
  801161:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801164:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801167:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80116d:	e8 c9 ef ff ff       	call   80013b <sys_getenvid>
  801172:	8b 55 0c             	mov    0xc(%ebp),%edx
  801175:	89 54 24 10          	mov    %edx,0x10(%esp)
  801179:	8b 55 08             	mov    0x8(%ebp),%edx
  80117c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801180:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801184:	89 44 24 04          	mov    %eax,0x4(%esp)
  801188:	c7 04 24 40 20 80 00 	movl   $0x802040,(%esp)
  80118f:	e8 c0 00 00 00       	call   801254 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801194:	89 74 24 04          	mov    %esi,0x4(%esp)
  801198:	8b 45 10             	mov    0x10(%ebp),%eax
  80119b:	89 04 24             	mov    %eax,(%esp)
  80119e:	e8 50 00 00 00       	call   8011f3 <vcprintf>
	cprintf("\n");
  8011a3:	c7 04 24 2d 20 80 00 	movl   $0x80202d,(%esp)
  8011aa:	e8 a5 00 00 00       	call   801254 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011af:	cc                   	int3   
  8011b0:	eb fd                	jmp    8011af <_panic+0x53>
	...

008011b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	53                   	push   %ebx
  8011b8:	83 ec 14             	sub    $0x14,%esp
  8011bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8011be:	8b 03                	mov    (%ebx),%eax
  8011c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8011c7:	40                   	inc    %eax
  8011c8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8011ca:	3d ff 00 00 00       	cmp    $0xff,%eax
  8011cf:	75 19                	jne    8011ea <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8011d1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8011d8:	00 
  8011d9:	8d 43 08             	lea    0x8(%ebx),%eax
  8011dc:	89 04 24             	mov    %eax,(%esp)
  8011df:	e8 c8 ee ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8011e4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8011ea:	ff 43 04             	incl   0x4(%ebx)
}
  8011ed:	83 c4 14             	add    $0x14,%esp
  8011f0:	5b                   	pop    %ebx
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8011fc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801203:	00 00 00 
	b.cnt = 0;
  801206:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80120d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801210:	8b 45 0c             	mov    0xc(%ebp),%eax
  801213:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801217:	8b 45 08             	mov    0x8(%ebp),%eax
  80121a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80121e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801224:	89 44 24 04          	mov    %eax,0x4(%esp)
  801228:	c7 04 24 b4 11 80 00 	movl   $0x8011b4,(%esp)
  80122f:	e8 82 01 00 00       	call   8013b6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801234:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80123a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801244:	89 04 24             	mov    %eax,(%esp)
  801247:	e8 60 ee ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80124c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801252:	c9                   	leave  
  801253:	c3                   	ret    

00801254 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80125a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80125d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801261:	8b 45 08             	mov    0x8(%ebp),%eax
  801264:	89 04 24             	mov    %eax,(%esp)
  801267:	e8 87 ff ff ff       	call   8011f3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    
	...

00801270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	57                   	push   %edi
  801274:	56                   	push   %esi
  801275:	53                   	push   %ebx
  801276:	83 ec 3c             	sub    $0x3c,%esp
  801279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80127c:	89 d7                	mov    %edx,%edi
  80127e:	8b 45 08             	mov    0x8(%ebp),%eax
  801281:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801284:	8b 45 0c             	mov    0xc(%ebp),%eax
  801287:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80128a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80128d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801290:	85 c0                	test   %eax,%eax
  801292:	75 08                	jne    80129c <printnum+0x2c>
  801294:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801297:	39 45 10             	cmp    %eax,0x10(%ebp)
  80129a:	77 57                	ja     8012f3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80129c:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012a0:	4b                   	dec    %ebx
  8012a1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8012a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012ac:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8012b0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8012b4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012bb:	00 
  8012bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012bf:	89 04 24             	mov    %eax,(%esp)
  8012c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c9:	e8 d2 09 00 00       	call   801ca0 <__udivdi3>
  8012ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012d2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012d6:	89 04 24             	mov    %eax,(%esp)
  8012d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012dd:	89 fa                	mov    %edi,%edx
  8012df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012e2:	e8 89 ff ff ff       	call   801270 <printnum>
  8012e7:	eb 0f                	jmp    8012f8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8012e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012ed:	89 34 24             	mov    %esi,(%esp)
  8012f0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8012f3:	4b                   	dec    %ebx
  8012f4:	85 db                	test   %ebx,%ebx
  8012f6:	7f f1                	jg     8012e9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8012f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012fc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801300:	8b 45 10             	mov    0x10(%ebp),%eax
  801303:	89 44 24 08          	mov    %eax,0x8(%esp)
  801307:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80130e:	00 
  80130f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801312:	89 04 24             	mov    %eax,(%esp)
  801315:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801318:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131c:	e8 9f 0a 00 00       	call   801dc0 <__umoddi3>
  801321:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801325:	0f be 80 63 20 80 00 	movsbl 0x802063(%eax),%eax
  80132c:	89 04 24             	mov    %eax,(%esp)
  80132f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801332:	83 c4 3c             	add    $0x3c,%esp
  801335:	5b                   	pop    %ebx
  801336:	5e                   	pop    %esi
  801337:	5f                   	pop    %edi
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    

0080133a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80133d:	83 fa 01             	cmp    $0x1,%edx
  801340:	7e 0e                	jle    801350 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801342:	8b 10                	mov    (%eax),%edx
  801344:	8d 4a 08             	lea    0x8(%edx),%ecx
  801347:	89 08                	mov    %ecx,(%eax)
  801349:	8b 02                	mov    (%edx),%eax
  80134b:	8b 52 04             	mov    0x4(%edx),%edx
  80134e:	eb 22                	jmp    801372 <getuint+0x38>
	else if (lflag)
  801350:	85 d2                	test   %edx,%edx
  801352:	74 10                	je     801364 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801354:	8b 10                	mov    (%eax),%edx
  801356:	8d 4a 04             	lea    0x4(%edx),%ecx
  801359:	89 08                	mov    %ecx,(%eax)
  80135b:	8b 02                	mov    (%edx),%eax
  80135d:	ba 00 00 00 00       	mov    $0x0,%edx
  801362:	eb 0e                	jmp    801372 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801364:	8b 10                	mov    (%eax),%edx
  801366:	8d 4a 04             	lea    0x4(%edx),%ecx
  801369:	89 08                	mov    %ecx,(%eax)
  80136b:	8b 02                	mov    (%edx),%eax
  80136d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80137a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80137d:	8b 10                	mov    (%eax),%edx
  80137f:	3b 50 04             	cmp    0x4(%eax),%edx
  801382:	73 08                	jae    80138c <sprintputch+0x18>
		*b->buf++ = ch;
  801384:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801387:	88 0a                	mov    %cl,(%edx)
  801389:	42                   	inc    %edx
  80138a:	89 10                	mov    %edx,(%eax)
}
  80138c:	5d                   	pop    %ebp
  80138d:	c3                   	ret    

0080138e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801394:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801397:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80139b:	8b 45 10             	mov    0x10(%ebp),%eax
  80139e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ac:	89 04 24             	mov    %eax,(%esp)
  8013af:	e8 02 00 00 00       	call   8013b6 <vprintfmt>
	va_end(ap);
}
  8013b4:	c9                   	leave  
  8013b5:	c3                   	ret    

008013b6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	57                   	push   %edi
  8013ba:	56                   	push   %esi
  8013bb:	53                   	push   %ebx
  8013bc:	83 ec 4c             	sub    $0x4c,%esp
  8013bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013c2:	8b 75 10             	mov    0x10(%ebp),%esi
  8013c5:	eb 12                	jmp    8013d9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	0f 84 8b 03 00 00    	je     80175a <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8013cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013d3:	89 04 24             	mov    %eax,(%esp)
  8013d6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8013d9:	0f b6 06             	movzbl (%esi),%eax
  8013dc:	46                   	inc    %esi
  8013dd:	83 f8 25             	cmp    $0x25,%eax
  8013e0:	75 e5                	jne    8013c7 <vprintfmt+0x11>
  8013e2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8013e6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8013ed:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8013f2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8013f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013fe:	eb 26                	jmp    801426 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801400:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801403:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801407:	eb 1d                	jmp    801426 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801409:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80140c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801410:	eb 14                	jmp    801426 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801412:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801415:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80141c:	eb 08                	jmp    801426 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80141e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801421:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801426:	0f b6 06             	movzbl (%esi),%eax
  801429:	8d 56 01             	lea    0x1(%esi),%edx
  80142c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80142f:	8a 16                	mov    (%esi),%dl
  801431:	83 ea 23             	sub    $0x23,%edx
  801434:	80 fa 55             	cmp    $0x55,%dl
  801437:	0f 87 01 03 00 00    	ja     80173e <vprintfmt+0x388>
  80143d:	0f b6 d2             	movzbl %dl,%edx
  801440:	ff 24 95 a0 21 80 00 	jmp    *0x8021a0(,%edx,4)
  801447:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80144a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80144f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801452:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  801456:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801459:	8d 50 d0             	lea    -0x30(%eax),%edx
  80145c:	83 fa 09             	cmp    $0x9,%edx
  80145f:	77 2a                	ja     80148b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801461:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801462:	eb eb                	jmp    80144f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801464:	8b 45 14             	mov    0x14(%ebp),%eax
  801467:	8d 50 04             	lea    0x4(%eax),%edx
  80146a:	89 55 14             	mov    %edx,0x14(%ebp)
  80146d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80146f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801472:	eb 17                	jmp    80148b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801474:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801478:	78 98                	js     801412 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80147a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80147d:	eb a7                	jmp    801426 <vprintfmt+0x70>
  80147f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801482:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801489:	eb 9b                	jmp    801426 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80148b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80148f:	79 95                	jns    801426 <vprintfmt+0x70>
  801491:	eb 8b                	jmp    80141e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801493:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801494:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801497:	eb 8d                	jmp    801426 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801499:	8b 45 14             	mov    0x14(%ebp),%eax
  80149c:	8d 50 04             	lea    0x4(%eax),%edx
  80149f:	89 55 14             	mov    %edx,0x14(%ebp)
  8014a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014a6:	8b 00                	mov    (%eax),%eax
  8014a8:	89 04 24             	mov    %eax,(%esp)
  8014ab:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8014b1:	e9 23 ff ff ff       	jmp    8013d9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8014b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b9:	8d 50 04             	lea    0x4(%eax),%edx
  8014bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8014bf:	8b 00                	mov    (%eax),%eax
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	79 02                	jns    8014c7 <vprintfmt+0x111>
  8014c5:	f7 d8                	neg    %eax
  8014c7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8014c9:	83 f8 0f             	cmp    $0xf,%eax
  8014cc:	7f 0b                	jg     8014d9 <vprintfmt+0x123>
  8014ce:	8b 04 85 00 23 80 00 	mov    0x802300(,%eax,4),%eax
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	75 23                	jne    8014fc <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8014d9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014dd:	c7 44 24 08 7b 20 80 	movl   $0x80207b,0x8(%esp)
  8014e4:	00 
  8014e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ec:	89 04 24             	mov    %eax,(%esp)
  8014ef:	e8 9a fe ff ff       	call   80138e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8014f7:	e9 dd fe ff ff       	jmp    8013d9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8014fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801500:	c7 44 24 08 06 20 80 	movl   $0x802006,0x8(%esp)
  801507:	00 
  801508:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80150c:	8b 55 08             	mov    0x8(%ebp),%edx
  80150f:	89 14 24             	mov    %edx,(%esp)
  801512:	e8 77 fe ff ff       	call   80138e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801517:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80151a:	e9 ba fe ff ff       	jmp    8013d9 <vprintfmt+0x23>
  80151f:	89 f9                	mov    %edi,%ecx
  801521:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801524:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801527:	8b 45 14             	mov    0x14(%ebp),%eax
  80152a:	8d 50 04             	lea    0x4(%eax),%edx
  80152d:	89 55 14             	mov    %edx,0x14(%ebp)
  801530:	8b 30                	mov    (%eax),%esi
  801532:	85 f6                	test   %esi,%esi
  801534:	75 05                	jne    80153b <vprintfmt+0x185>
				p = "(null)";
  801536:	be 74 20 80 00       	mov    $0x802074,%esi
			if (width > 0 && padc != '-')
  80153b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80153f:	0f 8e 84 00 00 00    	jle    8015c9 <vprintfmt+0x213>
  801545:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801549:	74 7e                	je     8015c9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80154b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80154f:	89 34 24             	mov    %esi,(%esp)
  801552:	e8 ab 02 00 00       	call   801802 <strnlen>
  801557:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80155a:	29 c2                	sub    %eax,%edx
  80155c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80155f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801563:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801566:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801569:	89 de                	mov    %ebx,%esi
  80156b:	89 d3                	mov    %edx,%ebx
  80156d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80156f:	eb 0b                	jmp    80157c <vprintfmt+0x1c6>
					putch(padc, putdat);
  801571:	89 74 24 04          	mov    %esi,0x4(%esp)
  801575:	89 3c 24             	mov    %edi,(%esp)
  801578:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80157b:	4b                   	dec    %ebx
  80157c:	85 db                	test   %ebx,%ebx
  80157e:	7f f1                	jg     801571 <vprintfmt+0x1bb>
  801580:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801583:	89 f3                	mov    %esi,%ebx
  801585:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801588:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80158b:	85 c0                	test   %eax,%eax
  80158d:	79 05                	jns    801594 <vprintfmt+0x1de>
  80158f:	b8 00 00 00 00       	mov    $0x0,%eax
  801594:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801597:	29 c2                	sub    %eax,%edx
  801599:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80159c:	eb 2b                	jmp    8015c9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80159e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8015a2:	74 18                	je     8015bc <vprintfmt+0x206>
  8015a4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8015a7:	83 fa 5e             	cmp    $0x5e,%edx
  8015aa:	76 10                	jbe    8015bc <vprintfmt+0x206>
					putch('?', putdat);
  8015ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015b0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8015b7:	ff 55 08             	call   *0x8(%ebp)
  8015ba:	eb 0a                	jmp    8015c6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8015bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015c0:	89 04 24             	mov    %eax,(%esp)
  8015c3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015c6:	ff 4d e4             	decl   -0x1c(%ebp)
  8015c9:	0f be 06             	movsbl (%esi),%eax
  8015cc:	46                   	inc    %esi
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	74 21                	je     8015f2 <vprintfmt+0x23c>
  8015d1:	85 ff                	test   %edi,%edi
  8015d3:	78 c9                	js     80159e <vprintfmt+0x1e8>
  8015d5:	4f                   	dec    %edi
  8015d6:	79 c6                	jns    80159e <vprintfmt+0x1e8>
  8015d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015db:	89 de                	mov    %ebx,%esi
  8015dd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8015e0:	eb 18                	jmp    8015fa <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8015e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015e6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8015ed:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8015ef:	4b                   	dec    %ebx
  8015f0:	eb 08                	jmp    8015fa <vprintfmt+0x244>
  8015f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015f5:	89 de                	mov    %ebx,%esi
  8015f7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8015fa:	85 db                	test   %ebx,%ebx
  8015fc:	7f e4                	jg     8015e2 <vprintfmt+0x22c>
  8015fe:	89 7d 08             	mov    %edi,0x8(%ebp)
  801601:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801603:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801606:	e9 ce fd ff ff       	jmp    8013d9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80160b:	83 f9 01             	cmp    $0x1,%ecx
  80160e:	7e 10                	jle    801620 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801610:	8b 45 14             	mov    0x14(%ebp),%eax
  801613:	8d 50 08             	lea    0x8(%eax),%edx
  801616:	89 55 14             	mov    %edx,0x14(%ebp)
  801619:	8b 30                	mov    (%eax),%esi
  80161b:	8b 78 04             	mov    0x4(%eax),%edi
  80161e:	eb 26                	jmp    801646 <vprintfmt+0x290>
	else if (lflag)
  801620:	85 c9                	test   %ecx,%ecx
  801622:	74 12                	je     801636 <vprintfmt+0x280>
		return va_arg(*ap, long);
  801624:	8b 45 14             	mov    0x14(%ebp),%eax
  801627:	8d 50 04             	lea    0x4(%eax),%edx
  80162a:	89 55 14             	mov    %edx,0x14(%ebp)
  80162d:	8b 30                	mov    (%eax),%esi
  80162f:	89 f7                	mov    %esi,%edi
  801631:	c1 ff 1f             	sar    $0x1f,%edi
  801634:	eb 10                	jmp    801646 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801636:	8b 45 14             	mov    0x14(%ebp),%eax
  801639:	8d 50 04             	lea    0x4(%eax),%edx
  80163c:	89 55 14             	mov    %edx,0x14(%ebp)
  80163f:	8b 30                	mov    (%eax),%esi
  801641:	89 f7                	mov    %esi,%edi
  801643:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801646:	85 ff                	test   %edi,%edi
  801648:	78 0a                	js     801654 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80164a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80164f:	e9 ac 00 00 00       	jmp    801700 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801654:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801658:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80165f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801662:	f7 de                	neg    %esi
  801664:	83 d7 00             	adc    $0x0,%edi
  801667:	f7 df                	neg    %edi
			}
			base = 10;
  801669:	b8 0a 00 00 00       	mov    $0xa,%eax
  80166e:	e9 8d 00 00 00       	jmp    801700 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801673:	89 ca                	mov    %ecx,%edx
  801675:	8d 45 14             	lea    0x14(%ebp),%eax
  801678:	e8 bd fc ff ff       	call   80133a <getuint>
  80167d:	89 c6                	mov    %eax,%esi
  80167f:	89 d7                	mov    %edx,%edi
			base = 10;
  801681:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801686:	eb 78                	jmp    801700 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801688:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80168c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  801693:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  801696:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80169a:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8016a1:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8016a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016a8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8016af:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8016b5:	e9 1f fd ff ff       	jmp    8013d9 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8016ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016be:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8016c5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8016c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016cc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8016d3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8016d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d9:	8d 50 04             	lea    0x4(%eax),%edx
  8016dc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8016df:	8b 30                	mov    (%eax),%esi
  8016e1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8016e6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8016eb:	eb 13                	jmp    801700 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8016ed:	89 ca                	mov    %ecx,%edx
  8016ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8016f2:	e8 43 fc ff ff       	call   80133a <getuint>
  8016f7:	89 c6                	mov    %eax,%esi
  8016f9:	89 d7                	mov    %edx,%edi
			base = 16;
  8016fb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801700:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801704:	89 54 24 10          	mov    %edx,0x10(%esp)
  801708:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80170b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80170f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801713:	89 34 24             	mov    %esi,(%esp)
  801716:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80171a:	89 da                	mov    %ebx,%edx
  80171c:	8b 45 08             	mov    0x8(%ebp),%eax
  80171f:	e8 4c fb ff ff       	call   801270 <printnum>
			break;
  801724:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801727:	e9 ad fc ff ff       	jmp    8013d9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80172c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801730:	89 04 24             	mov    %eax,(%esp)
  801733:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801736:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801739:	e9 9b fc ff ff       	jmp    8013d9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80173e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801742:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801749:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80174c:	eb 01                	jmp    80174f <vprintfmt+0x399>
  80174e:	4e                   	dec    %esi
  80174f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801753:	75 f9                	jne    80174e <vprintfmt+0x398>
  801755:	e9 7f fc ff ff       	jmp    8013d9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80175a:	83 c4 4c             	add    $0x4c,%esp
  80175d:	5b                   	pop    %ebx
  80175e:	5e                   	pop    %esi
  80175f:	5f                   	pop    %edi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	83 ec 28             	sub    $0x28,%esp
  801768:	8b 45 08             	mov    0x8(%ebp),%eax
  80176b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80176e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801771:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801775:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801778:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80177f:	85 c0                	test   %eax,%eax
  801781:	74 30                	je     8017b3 <vsnprintf+0x51>
  801783:	85 d2                	test   %edx,%edx
  801785:	7e 33                	jle    8017ba <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801787:	8b 45 14             	mov    0x14(%ebp),%eax
  80178a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80178e:	8b 45 10             	mov    0x10(%ebp),%eax
  801791:	89 44 24 08          	mov    %eax,0x8(%esp)
  801795:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801798:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179c:	c7 04 24 74 13 80 00 	movl   $0x801374,(%esp)
  8017a3:	e8 0e fc ff ff       	call   8013b6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8017a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8017ab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8017ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b1:	eb 0c                	jmp    8017bf <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8017b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017b8:	eb 05                	jmp    8017bf <vsnprintf+0x5d>
  8017ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8017bf:	c9                   	leave  
  8017c0:	c3                   	ret    

008017c1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8017c7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8017ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8017d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017df:	89 04 24             	mov    %eax,(%esp)
  8017e2:	e8 7b ff ff ff       	call   801762 <vsnprintf>
	va_end(ap);

	return rc;
}
  8017e7:	c9                   	leave  
  8017e8:	c3                   	ret    
  8017e9:	00 00                	add    %al,(%eax)
	...

008017ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8017f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f7:	eb 01                	jmp    8017fa <strlen+0xe>
		n++;
  8017f9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8017fa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8017fe:	75 f9                	jne    8017f9 <strlen+0xd>
		n++;
	return n;
}
  801800:	5d                   	pop    %ebp
  801801:	c3                   	ret    

00801802 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801808:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80180b:	b8 00 00 00 00       	mov    $0x0,%eax
  801810:	eb 01                	jmp    801813 <strnlen+0x11>
		n++;
  801812:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801813:	39 d0                	cmp    %edx,%eax
  801815:	74 06                	je     80181d <strnlen+0x1b>
  801817:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80181b:	75 f5                	jne    801812 <strnlen+0x10>
		n++;
	return n;
}
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	53                   	push   %ebx
  801823:	8b 45 08             	mov    0x8(%ebp),%eax
  801826:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801829:	ba 00 00 00 00       	mov    $0x0,%edx
  80182e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801831:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801834:	42                   	inc    %edx
  801835:	84 c9                	test   %cl,%cl
  801837:	75 f5                	jne    80182e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801839:	5b                   	pop    %ebx
  80183a:	5d                   	pop    %ebp
  80183b:	c3                   	ret    

0080183c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	53                   	push   %ebx
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801846:	89 1c 24             	mov    %ebx,(%esp)
  801849:	e8 9e ff ff ff       	call   8017ec <strlen>
	strcpy(dst + len, src);
  80184e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801851:	89 54 24 04          	mov    %edx,0x4(%esp)
  801855:	01 d8                	add    %ebx,%eax
  801857:	89 04 24             	mov    %eax,(%esp)
  80185a:	e8 c0 ff ff ff       	call   80181f <strcpy>
	return dst;
}
  80185f:	89 d8                	mov    %ebx,%eax
  801861:	83 c4 08             	add    $0x8,%esp
  801864:	5b                   	pop    %ebx
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	56                   	push   %esi
  80186b:	53                   	push   %ebx
  80186c:	8b 45 08             	mov    0x8(%ebp),%eax
  80186f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801872:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801875:	b9 00 00 00 00       	mov    $0x0,%ecx
  80187a:	eb 0c                	jmp    801888 <strncpy+0x21>
		*dst++ = *src;
  80187c:	8a 1a                	mov    (%edx),%bl
  80187e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801881:	80 3a 01             	cmpb   $0x1,(%edx)
  801884:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801887:	41                   	inc    %ecx
  801888:	39 f1                	cmp    %esi,%ecx
  80188a:	75 f0                	jne    80187c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80188c:	5b                   	pop    %ebx
  80188d:	5e                   	pop    %esi
  80188e:	5d                   	pop    %ebp
  80188f:	c3                   	ret    

00801890 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	56                   	push   %esi
  801894:	53                   	push   %ebx
  801895:	8b 75 08             	mov    0x8(%ebp),%esi
  801898:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80189b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80189e:	85 d2                	test   %edx,%edx
  8018a0:	75 0a                	jne    8018ac <strlcpy+0x1c>
  8018a2:	89 f0                	mov    %esi,%eax
  8018a4:	eb 1a                	jmp    8018c0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8018a6:	88 18                	mov    %bl,(%eax)
  8018a8:	40                   	inc    %eax
  8018a9:	41                   	inc    %ecx
  8018aa:	eb 02                	jmp    8018ae <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8018ac:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8018ae:	4a                   	dec    %edx
  8018af:	74 0a                	je     8018bb <strlcpy+0x2b>
  8018b1:	8a 19                	mov    (%ecx),%bl
  8018b3:	84 db                	test   %bl,%bl
  8018b5:	75 ef                	jne    8018a6 <strlcpy+0x16>
  8018b7:	89 c2                	mov    %eax,%edx
  8018b9:	eb 02                	jmp    8018bd <strlcpy+0x2d>
  8018bb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8018bd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8018c0:	29 f0                	sub    %esi,%eax
}
  8018c2:	5b                   	pop    %ebx
  8018c3:	5e                   	pop    %esi
  8018c4:	5d                   	pop    %ebp
  8018c5:	c3                   	ret    

008018c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
  8018c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8018cf:	eb 02                	jmp    8018d3 <strcmp+0xd>
		p++, q++;
  8018d1:	41                   	inc    %ecx
  8018d2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8018d3:	8a 01                	mov    (%ecx),%al
  8018d5:	84 c0                	test   %al,%al
  8018d7:	74 04                	je     8018dd <strcmp+0x17>
  8018d9:	3a 02                	cmp    (%edx),%al
  8018db:	74 f4                	je     8018d1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018dd:	0f b6 c0             	movzbl %al,%eax
  8018e0:	0f b6 12             	movzbl (%edx),%edx
  8018e3:	29 d0                	sub    %edx,%eax
}
  8018e5:	5d                   	pop    %ebp
  8018e6:	c3                   	ret    

008018e7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	53                   	push   %ebx
  8018eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018f1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8018f4:	eb 03                	jmp    8018f9 <strncmp+0x12>
		n--, p++, q++;
  8018f6:	4a                   	dec    %edx
  8018f7:	40                   	inc    %eax
  8018f8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8018f9:	85 d2                	test   %edx,%edx
  8018fb:	74 14                	je     801911 <strncmp+0x2a>
  8018fd:	8a 18                	mov    (%eax),%bl
  8018ff:	84 db                	test   %bl,%bl
  801901:	74 04                	je     801907 <strncmp+0x20>
  801903:	3a 19                	cmp    (%ecx),%bl
  801905:	74 ef                	je     8018f6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801907:	0f b6 00             	movzbl (%eax),%eax
  80190a:	0f b6 11             	movzbl (%ecx),%edx
  80190d:	29 d0                	sub    %edx,%eax
  80190f:	eb 05                	jmp    801916 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801911:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801916:	5b                   	pop    %ebx
  801917:	5d                   	pop    %ebp
  801918:	c3                   	ret    

00801919 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	8b 45 08             	mov    0x8(%ebp),%eax
  80191f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801922:	eb 05                	jmp    801929 <strchr+0x10>
		if (*s == c)
  801924:	38 ca                	cmp    %cl,%dl
  801926:	74 0c                	je     801934 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801928:	40                   	inc    %eax
  801929:	8a 10                	mov    (%eax),%dl
  80192b:	84 d2                	test   %dl,%dl
  80192d:	75 f5                	jne    801924 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80192f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801934:	5d                   	pop    %ebp
  801935:	c3                   	ret    

00801936 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	8b 45 08             	mov    0x8(%ebp),%eax
  80193c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80193f:	eb 05                	jmp    801946 <strfind+0x10>
		if (*s == c)
  801941:	38 ca                	cmp    %cl,%dl
  801943:	74 07                	je     80194c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801945:	40                   	inc    %eax
  801946:	8a 10                	mov    (%eax),%dl
  801948:	84 d2                	test   %dl,%dl
  80194a:	75 f5                	jne    801941 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	57                   	push   %edi
  801952:	56                   	push   %esi
  801953:	53                   	push   %ebx
  801954:	8b 7d 08             	mov    0x8(%ebp),%edi
  801957:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80195d:	85 c9                	test   %ecx,%ecx
  80195f:	74 30                	je     801991 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801961:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801967:	75 25                	jne    80198e <memset+0x40>
  801969:	f6 c1 03             	test   $0x3,%cl
  80196c:	75 20                	jne    80198e <memset+0x40>
		c &= 0xFF;
  80196e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801971:	89 d3                	mov    %edx,%ebx
  801973:	c1 e3 08             	shl    $0x8,%ebx
  801976:	89 d6                	mov    %edx,%esi
  801978:	c1 e6 18             	shl    $0x18,%esi
  80197b:	89 d0                	mov    %edx,%eax
  80197d:	c1 e0 10             	shl    $0x10,%eax
  801980:	09 f0                	or     %esi,%eax
  801982:	09 d0                	or     %edx,%eax
  801984:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801986:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801989:	fc                   	cld    
  80198a:	f3 ab                	rep stos %eax,%es:(%edi)
  80198c:	eb 03                	jmp    801991 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80198e:	fc                   	cld    
  80198f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801991:	89 f8                	mov    %edi,%eax
  801993:	5b                   	pop    %ebx
  801994:	5e                   	pop    %esi
  801995:	5f                   	pop    %edi
  801996:	5d                   	pop    %ebp
  801997:	c3                   	ret    

00801998 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	57                   	push   %edi
  80199c:	56                   	push   %esi
  80199d:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8019a6:	39 c6                	cmp    %eax,%esi
  8019a8:	73 34                	jae    8019de <memmove+0x46>
  8019aa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8019ad:	39 d0                	cmp    %edx,%eax
  8019af:	73 2d                	jae    8019de <memmove+0x46>
		s += n;
		d += n;
  8019b1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019b4:	f6 c2 03             	test   $0x3,%dl
  8019b7:	75 1b                	jne    8019d4 <memmove+0x3c>
  8019b9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019bf:	75 13                	jne    8019d4 <memmove+0x3c>
  8019c1:	f6 c1 03             	test   $0x3,%cl
  8019c4:	75 0e                	jne    8019d4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019c6:	83 ef 04             	sub    $0x4,%edi
  8019c9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019cc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8019cf:	fd                   	std    
  8019d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019d2:	eb 07                	jmp    8019db <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019d4:	4f                   	dec    %edi
  8019d5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8019d8:	fd                   	std    
  8019d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019db:	fc                   	cld    
  8019dc:	eb 20                	jmp    8019fe <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019de:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8019e4:	75 13                	jne    8019f9 <memmove+0x61>
  8019e6:	a8 03                	test   $0x3,%al
  8019e8:	75 0f                	jne    8019f9 <memmove+0x61>
  8019ea:	f6 c1 03             	test   $0x3,%cl
  8019ed:	75 0a                	jne    8019f9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019ef:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8019f2:	89 c7                	mov    %eax,%edi
  8019f4:	fc                   	cld    
  8019f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019f7:	eb 05                	jmp    8019fe <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8019f9:	89 c7                	mov    %eax,%edi
  8019fb:	fc                   	cld    
  8019fc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019fe:	5e                   	pop    %esi
  8019ff:	5f                   	pop    %edi
  801a00:	5d                   	pop    %ebp
  801a01:	c3                   	ret    

00801a02 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a08:	8b 45 10             	mov    0x10(%ebp),%eax
  801a0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a16:	8b 45 08             	mov    0x8(%ebp),%eax
  801a19:	89 04 24             	mov    %eax,(%esp)
  801a1c:	e8 77 ff ff ff       	call   801998 <memmove>
}
  801a21:	c9                   	leave  
  801a22:	c3                   	ret    

00801a23 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	57                   	push   %edi
  801a27:	56                   	push   %esi
  801a28:	53                   	push   %ebx
  801a29:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a32:	ba 00 00 00 00       	mov    $0x0,%edx
  801a37:	eb 16                	jmp    801a4f <memcmp+0x2c>
		if (*s1 != *s2)
  801a39:	8a 04 17             	mov    (%edi,%edx,1),%al
  801a3c:	42                   	inc    %edx
  801a3d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801a41:	38 c8                	cmp    %cl,%al
  801a43:	74 0a                	je     801a4f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801a45:	0f b6 c0             	movzbl %al,%eax
  801a48:	0f b6 c9             	movzbl %cl,%ecx
  801a4b:	29 c8                	sub    %ecx,%eax
  801a4d:	eb 09                	jmp    801a58 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a4f:	39 da                	cmp    %ebx,%edx
  801a51:	75 e6                	jne    801a39 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801a53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a58:	5b                   	pop    %ebx
  801a59:	5e                   	pop    %esi
  801a5a:	5f                   	pop    %edi
  801a5b:	5d                   	pop    %ebp
  801a5c:	c3                   	ret    

00801a5d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	8b 45 08             	mov    0x8(%ebp),%eax
  801a63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a66:	89 c2                	mov    %eax,%edx
  801a68:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a6b:	eb 05                	jmp    801a72 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a6d:	38 08                	cmp    %cl,(%eax)
  801a6f:	74 05                	je     801a76 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801a71:	40                   	inc    %eax
  801a72:	39 d0                	cmp    %edx,%eax
  801a74:	72 f7                	jb     801a6d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801a76:	5d                   	pop    %ebp
  801a77:	c3                   	ret    

00801a78 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	57                   	push   %edi
  801a7c:	56                   	push   %esi
  801a7d:	53                   	push   %ebx
  801a7e:	8b 55 08             	mov    0x8(%ebp),%edx
  801a81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a84:	eb 01                	jmp    801a87 <strtol+0xf>
		s++;
  801a86:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a87:	8a 02                	mov    (%edx),%al
  801a89:	3c 20                	cmp    $0x20,%al
  801a8b:	74 f9                	je     801a86 <strtol+0xe>
  801a8d:	3c 09                	cmp    $0x9,%al
  801a8f:	74 f5                	je     801a86 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801a91:	3c 2b                	cmp    $0x2b,%al
  801a93:	75 08                	jne    801a9d <strtol+0x25>
		s++;
  801a95:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801a96:	bf 00 00 00 00       	mov    $0x0,%edi
  801a9b:	eb 13                	jmp    801ab0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801a9d:	3c 2d                	cmp    $0x2d,%al
  801a9f:	75 0a                	jne    801aab <strtol+0x33>
		s++, neg = 1;
  801aa1:	8d 52 01             	lea    0x1(%edx),%edx
  801aa4:	bf 01 00 00 00       	mov    $0x1,%edi
  801aa9:	eb 05                	jmp    801ab0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801aab:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ab0:	85 db                	test   %ebx,%ebx
  801ab2:	74 05                	je     801ab9 <strtol+0x41>
  801ab4:	83 fb 10             	cmp    $0x10,%ebx
  801ab7:	75 28                	jne    801ae1 <strtol+0x69>
  801ab9:	8a 02                	mov    (%edx),%al
  801abb:	3c 30                	cmp    $0x30,%al
  801abd:	75 10                	jne    801acf <strtol+0x57>
  801abf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801ac3:	75 0a                	jne    801acf <strtol+0x57>
		s += 2, base = 16;
  801ac5:	83 c2 02             	add    $0x2,%edx
  801ac8:	bb 10 00 00 00       	mov    $0x10,%ebx
  801acd:	eb 12                	jmp    801ae1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801acf:	85 db                	test   %ebx,%ebx
  801ad1:	75 0e                	jne    801ae1 <strtol+0x69>
  801ad3:	3c 30                	cmp    $0x30,%al
  801ad5:	75 05                	jne    801adc <strtol+0x64>
		s++, base = 8;
  801ad7:	42                   	inc    %edx
  801ad8:	b3 08                	mov    $0x8,%bl
  801ada:	eb 05                	jmp    801ae1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801adc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ae8:	8a 0a                	mov    (%edx),%cl
  801aea:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801aed:	80 fb 09             	cmp    $0x9,%bl
  801af0:	77 08                	ja     801afa <strtol+0x82>
			dig = *s - '0';
  801af2:	0f be c9             	movsbl %cl,%ecx
  801af5:	83 e9 30             	sub    $0x30,%ecx
  801af8:	eb 1e                	jmp    801b18 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801afa:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801afd:	80 fb 19             	cmp    $0x19,%bl
  801b00:	77 08                	ja     801b0a <strtol+0x92>
			dig = *s - 'a' + 10;
  801b02:	0f be c9             	movsbl %cl,%ecx
  801b05:	83 e9 57             	sub    $0x57,%ecx
  801b08:	eb 0e                	jmp    801b18 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801b0a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801b0d:	80 fb 19             	cmp    $0x19,%bl
  801b10:	77 12                	ja     801b24 <strtol+0xac>
			dig = *s - 'A' + 10;
  801b12:	0f be c9             	movsbl %cl,%ecx
  801b15:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801b18:	39 f1                	cmp    %esi,%ecx
  801b1a:	7d 0c                	jge    801b28 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801b1c:	42                   	inc    %edx
  801b1d:	0f af c6             	imul   %esi,%eax
  801b20:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801b22:	eb c4                	jmp    801ae8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801b24:	89 c1                	mov    %eax,%ecx
  801b26:	eb 02                	jmp    801b2a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801b28:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801b2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b2e:	74 05                	je     801b35 <strtol+0xbd>
		*endptr = (char *) s;
  801b30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b33:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801b35:	85 ff                	test   %edi,%edi
  801b37:	74 04                	je     801b3d <strtol+0xc5>
  801b39:	89 c8                	mov    %ecx,%eax
  801b3b:	f7 d8                	neg    %eax
}
  801b3d:	5b                   	pop    %ebx
  801b3e:	5e                   	pop    %esi
  801b3f:	5f                   	pop    %edi
  801b40:	5d                   	pop    %ebp
  801b41:	c3                   	ret    
	...

00801b44 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	56                   	push   %esi
  801b48:	53                   	push   %ebx
  801b49:	83 ec 10             	sub    $0x10,%esp
  801b4c:	8b 75 08             	mov    0x8(%ebp),%esi
  801b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801b55:	85 c0                	test   %eax,%eax
  801b57:	75 05                	jne    801b5e <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801b59:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801b5e:	89 04 24             	mov    %eax,(%esp)
  801b61:	e8 29 e8 ff ff       	call   80038f <sys_ipc_recv>
	if (!err) {
  801b66:	85 c0                	test   %eax,%eax
  801b68:	75 26                	jne    801b90 <ipc_recv+0x4c>
		if (from_env_store) {
  801b6a:	85 f6                	test   %esi,%esi
  801b6c:	74 0a                	je     801b78 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801b6e:	a1 04 40 80 00       	mov    0x804004,%eax
  801b73:	8b 40 74             	mov    0x74(%eax),%eax
  801b76:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801b78:	85 db                	test   %ebx,%ebx
  801b7a:	74 0a                	je     801b86 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801b7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b81:	8b 40 78             	mov    0x78(%eax),%eax
  801b84:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801b86:	a1 04 40 80 00       	mov    0x804004,%eax
  801b8b:	8b 40 70             	mov    0x70(%eax),%eax
  801b8e:	eb 14                	jmp    801ba4 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801b90:	85 f6                	test   %esi,%esi
  801b92:	74 06                	je     801b9a <ipc_recv+0x56>
		*from_env_store = 0;
  801b94:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801b9a:	85 db                	test   %ebx,%ebx
  801b9c:	74 06                	je     801ba4 <ipc_recv+0x60>
		*perm_store = 0;
  801b9e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	5b                   	pop    %ebx
  801ba8:	5e                   	pop    %esi
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    

00801bab <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	57                   	push   %edi
  801baf:	56                   	push   %esi
  801bb0:	53                   	push   %ebx
  801bb1:	83 ec 1c             	sub    $0x1c,%esp
  801bb4:	8b 75 10             	mov    0x10(%ebp),%esi
  801bb7:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801bba:	85 f6                	test   %esi,%esi
  801bbc:	75 05                	jne    801bc3 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801bbe:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801bc3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801bc7:	89 74 24 08          	mov    %esi,0x8(%esp)
  801bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bce:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd5:	89 04 24             	mov    %eax,(%esp)
  801bd8:	e8 8f e7 ff ff       	call   80036c <sys_ipc_try_send>
  801bdd:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801bdf:	e8 76 e5 ff ff       	call   80015a <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801be4:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801be7:	74 da                	je     801bc3 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801be9:	85 db                	test   %ebx,%ebx
  801beb:	74 20                	je     801c0d <ipc_send+0x62>
		panic("send fail: %e", err);
  801bed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801bf1:	c7 44 24 08 60 23 80 	movl   $0x802360,0x8(%esp)
  801bf8:	00 
  801bf9:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801c00:	00 
  801c01:	c7 04 24 6e 23 80 00 	movl   $0x80236e,(%esp)
  801c08:	e8 4f f5 ff ff       	call   80115c <_panic>
	}
	return;
}
  801c0d:	83 c4 1c             	add    $0x1c,%esp
  801c10:	5b                   	pop    %ebx
  801c11:	5e                   	pop    %esi
  801c12:	5f                   	pop    %edi
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    

00801c15 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	53                   	push   %ebx
  801c19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c1c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c21:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c28:	89 c2                	mov    %eax,%edx
  801c2a:	c1 e2 07             	shl    $0x7,%edx
  801c2d:	29 ca                	sub    %ecx,%edx
  801c2f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c35:	8b 52 50             	mov    0x50(%edx),%edx
  801c38:	39 da                	cmp    %ebx,%edx
  801c3a:	75 0f                	jne    801c4b <ipc_find_env+0x36>
			return envs[i].env_id;
  801c3c:	c1 e0 07             	shl    $0x7,%eax
  801c3f:	29 c8                	sub    %ecx,%eax
  801c41:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c46:	8b 40 40             	mov    0x40(%eax),%eax
  801c49:	eb 0c                	jmp    801c57 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c4b:	40                   	inc    %eax
  801c4c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c51:	75 ce                	jne    801c21 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c53:	66 b8 00 00          	mov    $0x0,%ax
}
  801c57:	5b                   	pop    %ebx
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    
	...

00801c5c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c62:	89 c2                	mov    %eax,%edx
  801c64:	c1 ea 16             	shr    $0x16,%edx
  801c67:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c6e:	f6 c2 01             	test   $0x1,%dl
  801c71:	74 1e                	je     801c91 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c73:	c1 e8 0c             	shr    $0xc,%eax
  801c76:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c7d:	a8 01                	test   $0x1,%al
  801c7f:	74 17                	je     801c98 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c81:	c1 e8 0c             	shr    $0xc,%eax
  801c84:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c8b:	ef 
  801c8c:	0f b7 c0             	movzwl %ax,%eax
  801c8f:	eb 0c                	jmp    801c9d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c91:	b8 00 00 00 00       	mov    $0x0,%eax
  801c96:	eb 05                	jmp    801c9d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c98:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c9d:	5d                   	pop    %ebp
  801c9e:	c3                   	ret    
	...

00801ca0 <__udivdi3>:
  801ca0:	55                   	push   %ebp
  801ca1:	57                   	push   %edi
  801ca2:	56                   	push   %esi
  801ca3:	83 ec 10             	sub    $0x10,%esp
  801ca6:	8b 74 24 20          	mov    0x20(%esp),%esi
  801caa:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801cae:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cb2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cb6:	89 cd                	mov    %ecx,%ebp
  801cb8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	75 2c                	jne    801cec <__udivdi3+0x4c>
  801cc0:	39 f9                	cmp    %edi,%ecx
  801cc2:	77 68                	ja     801d2c <__udivdi3+0x8c>
  801cc4:	85 c9                	test   %ecx,%ecx
  801cc6:	75 0b                	jne    801cd3 <__udivdi3+0x33>
  801cc8:	b8 01 00 00 00       	mov    $0x1,%eax
  801ccd:	31 d2                	xor    %edx,%edx
  801ccf:	f7 f1                	div    %ecx
  801cd1:	89 c1                	mov    %eax,%ecx
  801cd3:	31 d2                	xor    %edx,%edx
  801cd5:	89 f8                	mov    %edi,%eax
  801cd7:	f7 f1                	div    %ecx
  801cd9:	89 c7                	mov    %eax,%edi
  801cdb:	89 f0                	mov    %esi,%eax
  801cdd:	f7 f1                	div    %ecx
  801cdf:	89 c6                	mov    %eax,%esi
  801ce1:	89 f0                	mov    %esi,%eax
  801ce3:	89 fa                	mov    %edi,%edx
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	5e                   	pop    %esi
  801ce9:	5f                   	pop    %edi
  801cea:	5d                   	pop    %ebp
  801ceb:	c3                   	ret    
  801cec:	39 f8                	cmp    %edi,%eax
  801cee:	77 2c                	ja     801d1c <__udivdi3+0x7c>
  801cf0:	0f bd f0             	bsr    %eax,%esi
  801cf3:	83 f6 1f             	xor    $0x1f,%esi
  801cf6:	75 4c                	jne    801d44 <__udivdi3+0xa4>
  801cf8:	39 f8                	cmp    %edi,%eax
  801cfa:	bf 00 00 00 00       	mov    $0x0,%edi
  801cff:	72 0a                	jb     801d0b <__udivdi3+0x6b>
  801d01:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d05:	0f 87 ad 00 00 00    	ja     801db8 <__udivdi3+0x118>
  801d0b:	be 01 00 00 00       	mov    $0x1,%esi
  801d10:	89 f0                	mov    %esi,%eax
  801d12:	89 fa                	mov    %edi,%edx
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	5e                   	pop    %esi
  801d18:	5f                   	pop    %edi
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    
  801d1b:	90                   	nop
  801d1c:	31 ff                	xor    %edi,%edi
  801d1e:	31 f6                	xor    %esi,%esi
  801d20:	89 f0                	mov    %esi,%eax
  801d22:	89 fa                	mov    %edi,%edx
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	5e                   	pop    %esi
  801d28:	5f                   	pop    %edi
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    
  801d2b:	90                   	nop
  801d2c:	89 fa                	mov    %edi,%edx
  801d2e:	89 f0                	mov    %esi,%eax
  801d30:	f7 f1                	div    %ecx
  801d32:	89 c6                	mov    %eax,%esi
  801d34:	31 ff                	xor    %edi,%edi
  801d36:	89 f0                	mov    %esi,%eax
  801d38:	89 fa                	mov    %edi,%edx
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	5e                   	pop    %esi
  801d3e:	5f                   	pop    %edi
  801d3f:	5d                   	pop    %ebp
  801d40:	c3                   	ret    
  801d41:	8d 76 00             	lea    0x0(%esi),%esi
  801d44:	89 f1                	mov    %esi,%ecx
  801d46:	d3 e0                	shl    %cl,%eax
  801d48:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d4c:	b8 20 00 00 00       	mov    $0x20,%eax
  801d51:	29 f0                	sub    %esi,%eax
  801d53:	89 ea                	mov    %ebp,%edx
  801d55:	88 c1                	mov    %al,%cl
  801d57:	d3 ea                	shr    %cl,%edx
  801d59:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801d5d:	09 ca                	or     %ecx,%edx
  801d5f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d63:	89 f1                	mov    %esi,%ecx
  801d65:	d3 e5                	shl    %cl,%ebp
  801d67:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801d6b:	89 fd                	mov    %edi,%ebp
  801d6d:	88 c1                	mov    %al,%cl
  801d6f:	d3 ed                	shr    %cl,%ebp
  801d71:	89 fa                	mov    %edi,%edx
  801d73:	89 f1                	mov    %esi,%ecx
  801d75:	d3 e2                	shl    %cl,%edx
  801d77:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d7b:	88 c1                	mov    %al,%cl
  801d7d:	d3 ef                	shr    %cl,%edi
  801d7f:	09 d7                	or     %edx,%edi
  801d81:	89 f8                	mov    %edi,%eax
  801d83:	89 ea                	mov    %ebp,%edx
  801d85:	f7 74 24 08          	divl   0x8(%esp)
  801d89:	89 d1                	mov    %edx,%ecx
  801d8b:	89 c7                	mov    %eax,%edi
  801d8d:	f7 64 24 0c          	mull   0xc(%esp)
  801d91:	39 d1                	cmp    %edx,%ecx
  801d93:	72 17                	jb     801dac <__udivdi3+0x10c>
  801d95:	74 09                	je     801da0 <__udivdi3+0x100>
  801d97:	89 fe                	mov    %edi,%esi
  801d99:	31 ff                	xor    %edi,%edi
  801d9b:	e9 41 ff ff ff       	jmp    801ce1 <__udivdi3+0x41>
  801da0:	8b 54 24 04          	mov    0x4(%esp),%edx
  801da4:	89 f1                	mov    %esi,%ecx
  801da6:	d3 e2                	shl    %cl,%edx
  801da8:	39 c2                	cmp    %eax,%edx
  801daa:	73 eb                	jae    801d97 <__udivdi3+0xf7>
  801dac:	8d 77 ff             	lea    -0x1(%edi),%esi
  801daf:	31 ff                	xor    %edi,%edi
  801db1:	e9 2b ff ff ff       	jmp    801ce1 <__udivdi3+0x41>
  801db6:	66 90                	xchg   %ax,%ax
  801db8:	31 f6                	xor    %esi,%esi
  801dba:	e9 22 ff ff ff       	jmp    801ce1 <__udivdi3+0x41>
	...

00801dc0 <__umoddi3>:
  801dc0:	55                   	push   %ebp
  801dc1:	57                   	push   %edi
  801dc2:	56                   	push   %esi
  801dc3:	83 ec 20             	sub    $0x20,%esp
  801dc6:	8b 44 24 30          	mov    0x30(%esp),%eax
  801dca:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801dce:	89 44 24 14          	mov    %eax,0x14(%esp)
  801dd2:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dd6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dda:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801dde:	89 c7                	mov    %eax,%edi
  801de0:	89 f2                	mov    %esi,%edx
  801de2:	85 ed                	test   %ebp,%ebp
  801de4:	75 16                	jne    801dfc <__umoddi3+0x3c>
  801de6:	39 f1                	cmp    %esi,%ecx
  801de8:	0f 86 a6 00 00 00    	jbe    801e94 <__umoddi3+0xd4>
  801dee:	f7 f1                	div    %ecx
  801df0:	89 d0                	mov    %edx,%eax
  801df2:	31 d2                	xor    %edx,%edx
  801df4:	83 c4 20             	add    $0x20,%esp
  801df7:	5e                   	pop    %esi
  801df8:	5f                   	pop    %edi
  801df9:	5d                   	pop    %ebp
  801dfa:	c3                   	ret    
  801dfb:	90                   	nop
  801dfc:	39 f5                	cmp    %esi,%ebp
  801dfe:	0f 87 ac 00 00 00    	ja     801eb0 <__umoddi3+0xf0>
  801e04:	0f bd c5             	bsr    %ebp,%eax
  801e07:	83 f0 1f             	xor    $0x1f,%eax
  801e0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e0e:	0f 84 a8 00 00 00    	je     801ebc <__umoddi3+0xfc>
  801e14:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e18:	d3 e5                	shl    %cl,%ebp
  801e1a:	bf 20 00 00 00       	mov    $0x20,%edi
  801e1f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e23:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e27:	89 f9                	mov    %edi,%ecx
  801e29:	d3 e8                	shr    %cl,%eax
  801e2b:	09 e8                	or     %ebp,%eax
  801e2d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e31:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e35:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e39:	d3 e0                	shl    %cl,%eax
  801e3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e3f:	89 f2                	mov    %esi,%edx
  801e41:	d3 e2                	shl    %cl,%edx
  801e43:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e47:	d3 e0                	shl    %cl,%eax
  801e49:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801e4d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e51:	89 f9                	mov    %edi,%ecx
  801e53:	d3 e8                	shr    %cl,%eax
  801e55:	09 d0                	or     %edx,%eax
  801e57:	d3 ee                	shr    %cl,%esi
  801e59:	89 f2                	mov    %esi,%edx
  801e5b:	f7 74 24 18          	divl   0x18(%esp)
  801e5f:	89 d6                	mov    %edx,%esi
  801e61:	f7 64 24 0c          	mull   0xc(%esp)
  801e65:	89 c5                	mov    %eax,%ebp
  801e67:	89 d1                	mov    %edx,%ecx
  801e69:	39 d6                	cmp    %edx,%esi
  801e6b:	72 67                	jb     801ed4 <__umoddi3+0x114>
  801e6d:	74 75                	je     801ee4 <__umoddi3+0x124>
  801e6f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e73:	29 e8                	sub    %ebp,%eax
  801e75:	19 ce                	sbb    %ecx,%esi
  801e77:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e7b:	d3 e8                	shr    %cl,%eax
  801e7d:	89 f2                	mov    %esi,%edx
  801e7f:	89 f9                	mov    %edi,%ecx
  801e81:	d3 e2                	shl    %cl,%edx
  801e83:	09 d0                	or     %edx,%eax
  801e85:	89 f2                	mov    %esi,%edx
  801e87:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e8b:	d3 ea                	shr    %cl,%edx
  801e8d:	83 c4 20             	add    $0x20,%esp
  801e90:	5e                   	pop    %esi
  801e91:	5f                   	pop    %edi
  801e92:	5d                   	pop    %ebp
  801e93:	c3                   	ret    
  801e94:	85 c9                	test   %ecx,%ecx
  801e96:	75 0b                	jne    801ea3 <__umoddi3+0xe3>
  801e98:	b8 01 00 00 00       	mov    $0x1,%eax
  801e9d:	31 d2                	xor    %edx,%edx
  801e9f:	f7 f1                	div    %ecx
  801ea1:	89 c1                	mov    %eax,%ecx
  801ea3:	89 f0                	mov    %esi,%eax
  801ea5:	31 d2                	xor    %edx,%edx
  801ea7:	f7 f1                	div    %ecx
  801ea9:	89 f8                	mov    %edi,%eax
  801eab:	e9 3e ff ff ff       	jmp    801dee <__umoddi3+0x2e>
  801eb0:	89 f2                	mov    %esi,%edx
  801eb2:	83 c4 20             	add    $0x20,%esp
  801eb5:	5e                   	pop    %esi
  801eb6:	5f                   	pop    %edi
  801eb7:	5d                   	pop    %ebp
  801eb8:	c3                   	ret    
  801eb9:	8d 76 00             	lea    0x0(%esi),%esi
  801ebc:	39 f5                	cmp    %esi,%ebp
  801ebe:	72 04                	jb     801ec4 <__umoddi3+0x104>
  801ec0:	39 f9                	cmp    %edi,%ecx
  801ec2:	77 06                	ja     801eca <__umoddi3+0x10a>
  801ec4:	89 f2                	mov    %esi,%edx
  801ec6:	29 cf                	sub    %ecx,%edi
  801ec8:	19 ea                	sbb    %ebp,%edx
  801eca:	89 f8                	mov    %edi,%eax
  801ecc:	83 c4 20             	add    $0x20,%esp
  801ecf:	5e                   	pop    %esi
  801ed0:	5f                   	pop    %edi
  801ed1:	5d                   	pop    %ebp
  801ed2:	c3                   	ret    
  801ed3:	90                   	nop
  801ed4:	89 d1                	mov    %edx,%ecx
  801ed6:	89 c5                	mov    %eax,%ebp
  801ed8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801edc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801ee0:	eb 8d                	jmp    801e6f <__umoddi3+0xaf>
  801ee2:	66 90                	xchg   %ax,%ax
  801ee4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801ee8:	72 ea                	jb     801ed4 <__umoddi3+0x114>
  801eea:	89 f1                	mov    %esi,%ecx
  801eec:	eb 81                	jmp    801e6f <__umoddi3+0xaf>

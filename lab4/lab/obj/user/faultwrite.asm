
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	83 ec 10             	sub    $0x10,%esp
  80004c:	8b 75 08             	mov    0x8(%ebp),%esi
  80004f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800052:	e8 e4 00 00 00       	call   80013b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800063:	c1 e0 07             	shl    $0x7,%eax
  800066:	29 d0                	sub    %edx,%eax
  800068:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800072:	85 f6                	test   %esi,%esi
  800074:	7e 07                	jle    80007d <libmain+0x39>
		binaryname = argv[0];
  800076:	8b 03                	mov    (%ebx),%eax
  800078:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800081:	89 34 24             	mov    %esi,(%esp)
  800084:	e8 ab ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800089:	e8 0a 00 00 00       	call   800098 <exit>
}
  80008e:	83 c4 10             	add    $0x10,%esp
  800091:	5b                   	pop    %ebx
  800092:	5e                   	pop    %esi
  800093:	5d                   	pop    %ebp
  800094:	c3                   	ret    
  800095:	00 00                	add    %al,(%eax)
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a5:	e8 3f 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

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
  800117:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800126:	00 
  800127:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  80012e:	e8 5d 02 00 00       	call   800390 <_panic>

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
  800165:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  8001a9:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  8001b0:	00 
  8001b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b8:	00 
  8001b9:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  8001c0:	e8 cb 01 00 00       	call   800390 <_panic>

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
  8001fc:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  800203:	00 
  800204:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020b:	00 
  80020c:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  800213:	e8 78 01 00 00       	call   800390 <_panic>

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
  80024f:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  800256:	00 
  800257:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025e:	00 
  80025f:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  800266:	e8 25 01 00 00       	call   800390 <_panic>

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
  8002a2:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  8002a9:	00 
  8002aa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b1:	00 
  8002b2:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  8002b9:	e8 d2 00 00 00       	call   800390 <_panic>

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

008002c6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  8002e7:	7e 28                	jle    800311 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ed:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f4:	00 
  8002f5:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  8002fc:	00 
  8002fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800304:	00 
  800305:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  80030c:	e8 7f 00 00 00       	call   800390 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800311:	83 c4 2c             	add    $0x2c,%esp
  800314:	5b                   	pop    %ebx
  800315:	5e                   	pop    %esi
  800316:	5f                   	pop    %edi
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    

00800319 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031f:	be 00 00 00 00       	mov    $0x0,%esi
  800324:	b8 0b 00 00 00       	mov    $0xb,%eax
  800329:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800332:	8b 55 08             	mov    0x8(%ebp),%edx
  800335:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800337:	5b                   	pop    %ebx
  800338:	5e                   	pop    %esi
  800339:	5f                   	pop    %edi
  80033a:	5d                   	pop    %ebp
  80033b:	c3                   	ret    

0080033c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	57                   	push   %edi
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
  800342:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800345:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80034f:	8b 55 08             	mov    0x8(%ebp),%edx
  800352:	89 cb                	mov    %ecx,%ebx
  800354:	89 cf                	mov    %ecx,%edi
  800356:	89 ce                	mov    %ecx,%esi
  800358:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80035a:	85 c0                	test   %eax,%eax
  80035c:	7e 28                	jle    800386 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800362:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800369:	00 
  80036a:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  800371:	00 
  800372:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800379:	00 
  80037a:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  800381:	e8 0a 00 00 00       	call   800390 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800386:	83 c4 2c             	add    $0x2c,%esp
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    
	...

00800390 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	56                   	push   %esi
  800394:	53                   	push   %ebx
  800395:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800398:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80039b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003a1:	e8 95 fd ff ff       	call   80013b <sys_getenvid>
  8003a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bc:	c7 04 24 18 10 80 00 	movl   $0x801018,(%esp)
  8003c3:	e8 c0 00 00 00       	call   800488 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cf:	89 04 24             	mov    %eax,(%esp)
  8003d2:	e8 50 00 00 00       	call   800427 <vcprintf>
	cprintf("\n");
  8003d7:	c7 04 24 3c 10 80 00 	movl   $0x80103c,(%esp)
  8003de:	e8 a5 00 00 00       	call   800488 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003e3:	cc                   	int3   
  8003e4:	eb fd                	jmp    8003e3 <_panic+0x53>
	...

008003e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	53                   	push   %ebx
  8003ec:	83 ec 14             	sub    $0x14,%esp
  8003ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003f2:	8b 03                	mov    (%ebx),%eax
  8003f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003fb:	40                   	inc    %eax
  8003fc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003fe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800403:	75 19                	jne    80041e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800405:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80040c:	00 
  80040d:	8d 43 08             	lea    0x8(%ebx),%eax
  800410:	89 04 24             	mov    %eax,(%esp)
  800413:	e8 94 fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  800418:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80041e:	ff 43 04             	incl   0x4(%ebx)
}
  800421:	83 c4 14             	add    $0x14,%esp
  800424:	5b                   	pop    %ebx
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800430:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800437:	00 00 00 
	b.cnt = 0;
  80043a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800441:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800444:	8b 45 0c             	mov    0xc(%ebp),%eax
  800447:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044b:	8b 45 08             	mov    0x8(%ebp),%eax
  80044e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800452:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800458:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045c:	c7 04 24 e8 03 80 00 	movl   $0x8003e8,(%esp)
  800463:	e8 82 01 00 00       	call   8005ea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800468:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80046e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800472:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800478:	89 04 24             	mov    %eax,(%esp)
  80047b:	e8 2c fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  800480:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800486:	c9                   	leave  
  800487:	c3                   	ret    

00800488 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80048e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800491:	89 44 24 04          	mov    %eax,0x4(%esp)
  800495:	8b 45 08             	mov    0x8(%ebp),%eax
  800498:	89 04 24             	mov    %eax,(%esp)
  80049b:	e8 87 ff ff ff       	call   800427 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004a0:	c9                   	leave  
  8004a1:	c3                   	ret    
	...

008004a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	57                   	push   %edi
  8004a8:	56                   	push   %esi
  8004a9:	53                   	push   %ebx
  8004aa:	83 ec 3c             	sub    $0x3c,%esp
  8004ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b0:	89 d7                	mov    %edx,%edi
  8004b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004be:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004c1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004c4:	85 c0                	test   %eax,%eax
  8004c6:	75 08                	jne    8004d0 <printnum+0x2c>
  8004c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004ce:	77 57                	ja     800527 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004d4:	4b                   	dec    %ebx
  8004d5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004e4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ef:	00 
  8004f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004f3:	89 04 24             	mov    %eax,(%esp)
  8004f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fd:	e8 76 08 00 00       	call   800d78 <__udivdi3>
  800502:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800506:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80050a:	89 04 24             	mov    %eax,(%esp)
  80050d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800511:	89 fa                	mov    %edi,%edx
  800513:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800516:	e8 89 ff ff ff       	call   8004a4 <printnum>
  80051b:	eb 0f                	jmp    80052c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80051d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800521:	89 34 24             	mov    %esi,(%esp)
  800524:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800527:	4b                   	dec    %ebx
  800528:	85 db                	test   %ebx,%ebx
  80052a:	7f f1                	jg     80051d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80052c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800530:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800534:	8b 45 10             	mov    0x10(%ebp),%eax
  800537:	89 44 24 08          	mov    %eax,0x8(%esp)
  80053b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800542:	00 
  800543:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800546:	89 04 24             	mov    %eax,(%esp)
  800549:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80054c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800550:	e8 43 09 00 00       	call   800e98 <__umoddi3>
  800555:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800559:	0f be 80 3e 10 80 00 	movsbl 0x80103e(%eax),%eax
  800560:	89 04 24             	mov    %eax,(%esp)
  800563:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800566:	83 c4 3c             	add    $0x3c,%esp
  800569:	5b                   	pop    %ebx
  80056a:	5e                   	pop    %esi
  80056b:	5f                   	pop    %edi
  80056c:	5d                   	pop    %ebp
  80056d:	c3                   	ret    

0080056e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800571:	83 fa 01             	cmp    $0x1,%edx
  800574:	7e 0e                	jle    800584 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800576:	8b 10                	mov    (%eax),%edx
  800578:	8d 4a 08             	lea    0x8(%edx),%ecx
  80057b:	89 08                	mov    %ecx,(%eax)
  80057d:	8b 02                	mov    (%edx),%eax
  80057f:	8b 52 04             	mov    0x4(%edx),%edx
  800582:	eb 22                	jmp    8005a6 <getuint+0x38>
	else if (lflag)
  800584:	85 d2                	test   %edx,%edx
  800586:	74 10                	je     800598 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800588:	8b 10                	mov    (%eax),%edx
  80058a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80058d:	89 08                	mov    %ecx,(%eax)
  80058f:	8b 02                	mov    (%edx),%eax
  800591:	ba 00 00 00 00       	mov    $0x0,%edx
  800596:	eb 0e                	jmp    8005a6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800598:	8b 10                	mov    (%eax),%edx
  80059a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80059d:	89 08                	mov    %ecx,(%eax)
  80059f:	8b 02                	mov    (%edx),%eax
  8005a1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005a6:	5d                   	pop    %ebp
  8005a7:	c3                   	ret    

008005a8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005a8:	55                   	push   %ebp
  8005a9:	89 e5                	mov    %esp,%ebp
  8005ab:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005ae:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005b1:	8b 10                	mov    (%eax),%edx
  8005b3:	3b 50 04             	cmp    0x4(%eax),%edx
  8005b6:	73 08                	jae    8005c0 <sprintputch+0x18>
		*b->buf++ = ch;
  8005b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005bb:	88 0a                	mov    %cl,(%edx)
  8005bd:	42                   	inc    %edx
  8005be:	89 10                	mov    %edx,(%eax)
}
  8005c0:	5d                   	pop    %ebp
  8005c1:	c3                   	ret    

008005c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005c2:	55                   	push   %ebp
  8005c3:	89 e5                	mov    %esp,%ebp
  8005c5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8005d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e0:	89 04 24             	mov    %eax,(%esp)
  8005e3:	e8 02 00 00 00       	call   8005ea <vprintfmt>
	va_end(ap);
}
  8005e8:	c9                   	leave  
  8005e9:	c3                   	ret    

008005ea <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005ea:	55                   	push   %ebp
  8005eb:	89 e5                	mov    %esp,%ebp
  8005ed:	57                   	push   %edi
  8005ee:	56                   	push   %esi
  8005ef:	53                   	push   %ebx
  8005f0:	83 ec 4c             	sub    $0x4c,%esp
  8005f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f6:	8b 75 10             	mov    0x10(%ebp),%esi
  8005f9:	eb 12                	jmp    80060d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	0f 84 8b 03 00 00    	je     80098e <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800603:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800607:	89 04 24             	mov    %eax,(%esp)
  80060a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80060d:	0f b6 06             	movzbl (%esi),%eax
  800610:	46                   	inc    %esi
  800611:	83 f8 25             	cmp    $0x25,%eax
  800614:	75 e5                	jne    8005fb <vprintfmt+0x11>
  800616:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80061a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800621:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800626:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80062d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800632:	eb 26                	jmp    80065a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800634:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800637:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80063b:	eb 1d                	jmp    80065a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800640:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800644:	eb 14                	jmp    80065a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800649:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800650:	eb 08                	jmp    80065a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800652:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800655:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065a:	0f b6 06             	movzbl (%esi),%eax
  80065d:	8d 56 01             	lea    0x1(%esi),%edx
  800660:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800663:	8a 16                	mov    (%esi),%dl
  800665:	83 ea 23             	sub    $0x23,%edx
  800668:	80 fa 55             	cmp    $0x55,%dl
  80066b:	0f 87 01 03 00 00    	ja     800972 <vprintfmt+0x388>
  800671:	0f b6 d2             	movzbl %dl,%edx
  800674:	ff 24 95 00 11 80 00 	jmp    *0x801100(,%edx,4)
  80067b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80067e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800683:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800686:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80068a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80068d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800690:	83 fa 09             	cmp    $0x9,%edx
  800693:	77 2a                	ja     8006bf <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800695:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800696:	eb eb                	jmp    800683 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006a6:	eb 17                	jmp    8006bf <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006ac:	78 98                	js     800646 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b1:	eb a7                	jmp    80065a <vprintfmt+0x70>
  8006b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006b6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006bd:	eb 9b                	jmp    80065a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006c3:	79 95                	jns    80065a <vprintfmt+0x70>
  8006c5:	eb 8b                	jmp    800652 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006c7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006cb:	eb 8d                	jmp    80065a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8d 50 04             	lea    0x4(%eax),%edx
  8006d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	89 04 24             	mov    %eax,(%esp)
  8006df:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006e5:	e9 23 ff ff ff       	jmp    80060d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8d 50 04             	lea    0x4(%eax),%edx
  8006f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f3:	8b 00                	mov    (%eax),%eax
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	79 02                	jns    8006fb <vprintfmt+0x111>
  8006f9:	f7 d8                	neg    %eax
  8006fb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006fd:	83 f8 08             	cmp    $0x8,%eax
  800700:	7f 0b                	jg     80070d <vprintfmt+0x123>
  800702:	8b 04 85 60 12 80 00 	mov    0x801260(,%eax,4),%eax
  800709:	85 c0                	test   %eax,%eax
  80070b:	75 23                	jne    800730 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80070d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800711:	c7 44 24 08 56 10 80 	movl   $0x801056,0x8(%esp)
  800718:	00 
  800719:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	e8 9a fe ff ff       	call   8005c2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800728:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80072b:	e9 dd fe ff ff       	jmp    80060d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800730:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800734:	c7 44 24 08 5f 10 80 	movl   $0x80105f,0x8(%esp)
  80073b:	00 
  80073c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800740:	8b 55 08             	mov    0x8(%ebp),%edx
  800743:	89 14 24             	mov    %edx,(%esp)
  800746:	e8 77 fe ff ff       	call   8005c2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80074e:	e9 ba fe ff ff       	jmp    80060d <vprintfmt+0x23>
  800753:	89 f9                	mov    %edi,%ecx
  800755:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800758:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8d 50 04             	lea    0x4(%eax),%edx
  800761:	89 55 14             	mov    %edx,0x14(%ebp)
  800764:	8b 30                	mov    (%eax),%esi
  800766:	85 f6                	test   %esi,%esi
  800768:	75 05                	jne    80076f <vprintfmt+0x185>
				p = "(null)";
  80076a:	be 4f 10 80 00       	mov    $0x80104f,%esi
			if (width > 0 && padc != '-')
  80076f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800773:	0f 8e 84 00 00 00    	jle    8007fd <vprintfmt+0x213>
  800779:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80077d:	74 7e                	je     8007fd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80077f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800783:	89 34 24             	mov    %esi,(%esp)
  800786:	e8 ab 02 00 00       	call   800a36 <strnlen>
  80078b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80078e:	29 c2                	sub    %eax,%edx
  800790:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800793:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800797:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80079a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80079d:	89 de                	mov    %ebx,%esi
  80079f:	89 d3                	mov    %edx,%ebx
  8007a1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a3:	eb 0b                	jmp    8007b0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a9:	89 3c 24             	mov    %edi,(%esp)
  8007ac:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007af:	4b                   	dec    %ebx
  8007b0:	85 db                	test   %ebx,%ebx
  8007b2:	7f f1                	jg     8007a5 <vprintfmt+0x1bb>
  8007b4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007b7:	89 f3                	mov    %esi,%ebx
  8007b9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	79 05                	jns    8007c8 <vprintfmt+0x1de>
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007cb:	29 c2                	sub    %eax,%edx
  8007cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007d0:	eb 2b                	jmp    8007fd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007d2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007d6:	74 18                	je     8007f0 <vprintfmt+0x206>
  8007d8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007db:	83 fa 5e             	cmp    $0x5e,%edx
  8007de:	76 10                	jbe    8007f0 <vprintfmt+0x206>
					putch('?', putdat);
  8007e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007eb:	ff 55 08             	call   *0x8(%ebp)
  8007ee:	eb 0a                	jmp    8007fa <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f4:	89 04 24             	mov    %eax,(%esp)
  8007f7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007fa:	ff 4d e4             	decl   -0x1c(%ebp)
  8007fd:	0f be 06             	movsbl (%esi),%eax
  800800:	46                   	inc    %esi
  800801:	85 c0                	test   %eax,%eax
  800803:	74 21                	je     800826 <vprintfmt+0x23c>
  800805:	85 ff                	test   %edi,%edi
  800807:	78 c9                	js     8007d2 <vprintfmt+0x1e8>
  800809:	4f                   	dec    %edi
  80080a:	79 c6                	jns    8007d2 <vprintfmt+0x1e8>
  80080c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80080f:	89 de                	mov    %ebx,%esi
  800811:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800814:	eb 18                	jmp    80082e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800816:	89 74 24 04          	mov    %esi,0x4(%esp)
  80081a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800821:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800823:	4b                   	dec    %ebx
  800824:	eb 08                	jmp    80082e <vprintfmt+0x244>
  800826:	8b 7d 08             	mov    0x8(%ebp),%edi
  800829:	89 de                	mov    %ebx,%esi
  80082b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80082e:	85 db                	test   %ebx,%ebx
  800830:	7f e4                	jg     800816 <vprintfmt+0x22c>
  800832:	89 7d 08             	mov    %edi,0x8(%ebp)
  800835:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800837:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80083a:	e9 ce fd ff ff       	jmp    80060d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80083f:	83 f9 01             	cmp    $0x1,%ecx
  800842:	7e 10                	jle    800854 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800844:	8b 45 14             	mov    0x14(%ebp),%eax
  800847:	8d 50 08             	lea    0x8(%eax),%edx
  80084a:	89 55 14             	mov    %edx,0x14(%ebp)
  80084d:	8b 30                	mov    (%eax),%esi
  80084f:	8b 78 04             	mov    0x4(%eax),%edi
  800852:	eb 26                	jmp    80087a <vprintfmt+0x290>
	else if (lflag)
  800854:	85 c9                	test   %ecx,%ecx
  800856:	74 12                	je     80086a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800858:	8b 45 14             	mov    0x14(%ebp),%eax
  80085b:	8d 50 04             	lea    0x4(%eax),%edx
  80085e:	89 55 14             	mov    %edx,0x14(%ebp)
  800861:	8b 30                	mov    (%eax),%esi
  800863:	89 f7                	mov    %esi,%edi
  800865:	c1 ff 1f             	sar    $0x1f,%edi
  800868:	eb 10                	jmp    80087a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80086a:	8b 45 14             	mov    0x14(%ebp),%eax
  80086d:	8d 50 04             	lea    0x4(%eax),%edx
  800870:	89 55 14             	mov    %edx,0x14(%ebp)
  800873:	8b 30                	mov    (%eax),%esi
  800875:	89 f7                	mov    %esi,%edi
  800877:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80087a:	85 ff                	test   %edi,%edi
  80087c:	78 0a                	js     800888 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80087e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800883:	e9 ac 00 00 00       	jmp    800934 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800888:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800893:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800896:	f7 de                	neg    %esi
  800898:	83 d7 00             	adc    $0x0,%edi
  80089b:	f7 df                	neg    %edi
			}
			base = 10;
  80089d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008a2:	e9 8d 00 00 00       	jmp    800934 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008a7:	89 ca                	mov    %ecx,%edx
  8008a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ac:	e8 bd fc ff ff       	call   80056e <getuint>
  8008b1:	89 c6                	mov    %eax,%esi
  8008b3:	89 d7                	mov    %edx,%edi
			base = 10;
  8008b5:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008ba:	eb 78                	jmp    800934 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8008bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008c7:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8008ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ce:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008d5:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8008d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008dc:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008e3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8008e9:	e9 1f fd ff ff       	jmp    80060d <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8008ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008f9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800900:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800907:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80090a:	8b 45 14             	mov    0x14(%ebp),%eax
  80090d:	8d 50 04             	lea    0x4(%eax),%edx
  800910:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800913:	8b 30                	mov    (%eax),%esi
  800915:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80091a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80091f:	eb 13                	jmp    800934 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800921:	89 ca                	mov    %ecx,%edx
  800923:	8d 45 14             	lea    0x14(%ebp),%eax
  800926:	e8 43 fc ff ff       	call   80056e <getuint>
  80092b:	89 c6                	mov    %eax,%esi
  80092d:	89 d7                	mov    %edx,%edi
			base = 16;
  80092f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800934:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800938:	89 54 24 10          	mov    %edx,0x10(%esp)
  80093c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80093f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800943:	89 44 24 08          	mov    %eax,0x8(%esp)
  800947:	89 34 24             	mov    %esi,(%esp)
  80094a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80094e:	89 da                	mov    %ebx,%edx
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	e8 4c fb ff ff       	call   8004a4 <printnum>
			break;
  800958:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80095b:	e9 ad fc ff ff       	jmp    80060d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800960:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800964:	89 04 24             	mov    %eax,(%esp)
  800967:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80096d:	e9 9b fc ff ff       	jmp    80060d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800972:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800976:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80097d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800980:	eb 01                	jmp    800983 <vprintfmt+0x399>
  800982:	4e                   	dec    %esi
  800983:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800987:	75 f9                	jne    800982 <vprintfmt+0x398>
  800989:	e9 7f fc ff ff       	jmp    80060d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80098e:	83 c4 4c             	add    $0x4c,%esp
  800991:	5b                   	pop    %ebx
  800992:	5e                   	pop    %esi
  800993:	5f                   	pop    %edi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 28             	sub    $0x28,%esp
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009a5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009a9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009b3:	85 c0                	test   %eax,%eax
  8009b5:	74 30                	je     8009e7 <vsnprintf+0x51>
  8009b7:	85 d2                	test   %edx,%edx
  8009b9:	7e 33                	jle    8009ee <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8009be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d0:	c7 04 24 a8 05 80 00 	movl   $0x8005a8,(%esp)
  8009d7:	e8 0e fc ff ff       	call   8005ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009df:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009e5:	eb 0c                	jmp    8009f3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009ec:	eb 05                	jmp    8009f3 <vsnprintf+0x5d>
  8009ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009f3:	c9                   	leave  
  8009f4:	c3                   	ret    

008009f5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009fb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a02:	8b 45 10             	mov    0x10(%ebp),%eax
  800a05:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	89 04 24             	mov    %eax,(%esp)
  800a16:	e8 7b ff ff ff       	call   800996 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a1b:	c9                   	leave  
  800a1c:	c3                   	ret    
  800a1d:	00 00                	add    %al,(%eax)
	...

00800a20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2b:	eb 01                	jmp    800a2e <strlen+0xe>
		n++;
  800a2d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a2e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a32:	75 f9                	jne    800a2d <strlen+0xd>
		n++;
	return n;
}
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a3c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a44:	eb 01                	jmp    800a47 <strnlen+0x11>
		n++;
  800a46:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a47:	39 d0                	cmp    %edx,%eax
  800a49:	74 06                	je     800a51 <strnlen+0x1b>
  800a4b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a4f:	75 f5                	jne    800a46 <strnlen+0x10>
		n++;
	return n;
}
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	53                   	push   %ebx
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a62:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a65:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a68:	42                   	inc    %edx
  800a69:	84 c9                	test   %cl,%cl
  800a6b:	75 f5                	jne    800a62 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a6d:	5b                   	pop    %ebx
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	53                   	push   %ebx
  800a74:	83 ec 08             	sub    $0x8,%esp
  800a77:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a7a:	89 1c 24             	mov    %ebx,(%esp)
  800a7d:	e8 9e ff ff ff       	call   800a20 <strlen>
	strcpy(dst + len, src);
  800a82:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a85:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a89:	01 d8                	add    %ebx,%eax
  800a8b:	89 04 24             	mov    %eax,(%esp)
  800a8e:	e8 c0 ff ff ff       	call   800a53 <strcpy>
	return dst;
}
  800a93:	89 d8                	mov    %ebx,%eax
  800a95:	83 c4 08             	add    $0x8,%esp
  800a98:	5b                   	pop    %ebx
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aae:	eb 0c                	jmp    800abc <strncpy+0x21>
		*dst++ = *src;
  800ab0:	8a 1a                	mov    (%edx),%bl
  800ab2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ab5:	80 3a 01             	cmpb   $0x1,(%edx)
  800ab8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800abb:	41                   	inc    %ecx
  800abc:	39 f1                	cmp    %esi,%ecx
  800abe:	75 f0                	jne    800ab0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	8b 75 08             	mov    0x8(%ebp),%esi
  800acc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ad2:	85 d2                	test   %edx,%edx
  800ad4:	75 0a                	jne    800ae0 <strlcpy+0x1c>
  800ad6:	89 f0                	mov    %esi,%eax
  800ad8:	eb 1a                	jmp    800af4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ada:	88 18                	mov    %bl,(%eax)
  800adc:	40                   	inc    %eax
  800add:	41                   	inc    %ecx
  800ade:	eb 02                	jmp    800ae2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800ae2:	4a                   	dec    %edx
  800ae3:	74 0a                	je     800aef <strlcpy+0x2b>
  800ae5:	8a 19                	mov    (%ecx),%bl
  800ae7:	84 db                	test   %bl,%bl
  800ae9:	75 ef                	jne    800ada <strlcpy+0x16>
  800aeb:	89 c2                	mov    %eax,%edx
  800aed:	eb 02                	jmp    800af1 <strlcpy+0x2d>
  800aef:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800af1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800af4:	29 f0                	sub    %esi,%eax
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b00:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b03:	eb 02                	jmp    800b07 <strcmp+0xd>
		p++, q++;
  800b05:	41                   	inc    %ecx
  800b06:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b07:	8a 01                	mov    (%ecx),%al
  800b09:	84 c0                	test   %al,%al
  800b0b:	74 04                	je     800b11 <strcmp+0x17>
  800b0d:	3a 02                	cmp    (%edx),%al
  800b0f:	74 f4                	je     800b05 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b11:	0f b6 c0             	movzbl %al,%eax
  800b14:	0f b6 12             	movzbl (%edx),%edx
  800b17:	29 d0                	sub    %edx,%eax
}
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	53                   	push   %ebx
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b25:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b28:	eb 03                	jmp    800b2d <strncmp+0x12>
		n--, p++, q++;
  800b2a:	4a                   	dec    %edx
  800b2b:	40                   	inc    %eax
  800b2c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b2d:	85 d2                	test   %edx,%edx
  800b2f:	74 14                	je     800b45 <strncmp+0x2a>
  800b31:	8a 18                	mov    (%eax),%bl
  800b33:	84 db                	test   %bl,%bl
  800b35:	74 04                	je     800b3b <strncmp+0x20>
  800b37:	3a 19                	cmp    (%ecx),%bl
  800b39:	74 ef                	je     800b2a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b3b:	0f b6 00             	movzbl (%eax),%eax
  800b3e:	0f b6 11             	movzbl (%ecx),%edx
  800b41:	29 d0                	sub    %edx,%eax
  800b43:	eb 05                	jmp    800b4a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b45:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b56:	eb 05                	jmp    800b5d <strchr+0x10>
		if (*s == c)
  800b58:	38 ca                	cmp    %cl,%dl
  800b5a:	74 0c                	je     800b68 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b5c:	40                   	inc    %eax
  800b5d:	8a 10                	mov    (%eax),%dl
  800b5f:	84 d2                	test   %dl,%dl
  800b61:	75 f5                	jne    800b58 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b70:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b73:	eb 05                	jmp    800b7a <strfind+0x10>
		if (*s == c)
  800b75:	38 ca                	cmp    %cl,%dl
  800b77:	74 07                	je     800b80 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b79:	40                   	inc    %eax
  800b7a:	8a 10                	mov    (%eax),%dl
  800b7c:	84 d2                	test   %dl,%dl
  800b7e:	75 f5                	jne    800b75 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b91:	85 c9                	test   %ecx,%ecx
  800b93:	74 30                	je     800bc5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b95:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b9b:	75 25                	jne    800bc2 <memset+0x40>
  800b9d:	f6 c1 03             	test   $0x3,%cl
  800ba0:	75 20                	jne    800bc2 <memset+0x40>
		c &= 0xFF;
  800ba2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ba5:	89 d3                	mov    %edx,%ebx
  800ba7:	c1 e3 08             	shl    $0x8,%ebx
  800baa:	89 d6                	mov    %edx,%esi
  800bac:	c1 e6 18             	shl    $0x18,%esi
  800baf:	89 d0                	mov    %edx,%eax
  800bb1:	c1 e0 10             	shl    $0x10,%eax
  800bb4:	09 f0                	or     %esi,%eax
  800bb6:	09 d0                	or     %edx,%eax
  800bb8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bba:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bbd:	fc                   	cld    
  800bbe:	f3 ab                	rep stos %eax,%es:(%edi)
  800bc0:	eb 03                	jmp    800bc5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bc2:	fc                   	cld    
  800bc3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bc5:	89 f8                	mov    %edi,%eax
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bda:	39 c6                	cmp    %eax,%esi
  800bdc:	73 34                	jae    800c12 <memmove+0x46>
  800bde:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800be1:	39 d0                	cmp    %edx,%eax
  800be3:	73 2d                	jae    800c12 <memmove+0x46>
		s += n;
		d += n;
  800be5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be8:	f6 c2 03             	test   $0x3,%dl
  800beb:	75 1b                	jne    800c08 <memmove+0x3c>
  800bed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bf3:	75 13                	jne    800c08 <memmove+0x3c>
  800bf5:	f6 c1 03             	test   $0x3,%cl
  800bf8:	75 0e                	jne    800c08 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bfa:	83 ef 04             	sub    $0x4,%edi
  800bfd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c00:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c03:	fd                   	std    
  800c04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c06:	eb 07                	jmp    800c0f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c08:	4f                   	dec    %edi
  800c09:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c0c:	fd                   	std    
  800c0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c0f:	fc                   	cld    
  800c10:	eb 20                	jmp    800c32 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c12:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c18:	75 13                	jne    800c2d <memmove+0x61>
  800c1a:	a8 03                	test   $0x3,%al
  800c1c:	75 0f                	jne    800c2d <memmove+0x61>
  800c1e:	f6 c1 03             	test   $0x3,%cl
  800c21:	75 0a                	jne    800c2d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c23:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c26:	89 c7                	mov    %eax,%edi
  800c28:	fc                   	cld    
  800c29:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c2b:	eb 05                	jmp    800c32 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c2d:	89 c7                	mov    %eax,%edi
  800c2f:	fc                   	cld    
  800c30:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c46:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4d:	89 04 24             	mov    %eax,(%esp)
  800c50:	e8 77 ff ff ff       	call   800bcc <memmove>
}
  800c55:	c9                   	leave  
  800c56:	c3                   	ret    

00800c57 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c60:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c66:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6b:	eb 16                	jmp    800c83 <memcmp+0x2c>
		if (*s1 != *s2)
  800c6d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c70:	42                   	inc    %edx
  800c71:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c75:	38 c8                	cmp    %cl,%al
  800c77:	74 0a                	je     800c83 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c79:	0f b6 c0             	movzbl %al,%eax
  800c7c:	0f b6 c9             	movzbl %cl,%ecx
  800c7f:	29 c8                	sub    %ecx,%eax
  800c81:	eb 09                	jmp    800c8c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c83:	39 da                	cmp    %ebx,%edx
  800c85:	75 e6                	jne    800c6d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	8b 45 08             	mov    0x8(%ebp),%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c9a:	89 c2                	mov    %eax,%edx
  800c9c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c9f:	eb 05                	jmp    800ca6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ca1:	38 08                	cmp    %cl,(%eax)
  800ca3:	74 05                	je     800caa <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ca5:	40                   	inc    %eax
  800ca6:	39 d0                	cmp    %edx,%eax
  800ca8:	72 f7                	jb     800ca1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb8:	eb 01                	jmp    800cbb <strtol+0xf>
		s++;
  800cba:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cbb:	8a 02                	mov    (%edx),%al
  800cbd:	3c 20                	cmp    $0x20,%al
  800cbf:	74 f9                	je     800cba <strtol+0xe>
  800cc1:	3c 09                	cmp    $0x9,%al
  800cc3:	74 f5                	je     800cba <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cc5:	3c 2b                	cmp    $0x2b,%al
  800cc7:	75 08                	jne    800cd1 <strtol+0x25>
		s++;
  800cc9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cca:	bf 00 00 00 00       	mov    $0x0,%edi
  800ccf:	eb 13                	jmp    800ce4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cd1:	3c 2d                	cmp    $0x2d,%al
  800cd3:	75 0a                	jne    800cdf <strtol+0x33>
		s++, neg = 1;
  800cd5:	8d 52 01             	lea    0x1(%edx),%edx
  800cd8:	bf 01 00 00 00       	mov    $0x1,%edi
  800cdd:	eb 05                	jmp    800ce4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cdf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ce4:	85 db                	test   %ebx,%ebx
  800ce6:	74 05                	je     800ced <strtol+0x41>
  800ce8:	83 fb 10             	cmp    $0x10,%ebx
  800ceb:	75 28                	jne    800d15 <strtol+0x69>
  800ced:	8a 02                	mov    (%edx),%al
  800cef:	3c 30                	cmp    $0x30,%al
  800cf1:	75 10                	jne    800d03 <strtol+0x57>
  800cf3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cf7:	75 0a                	jne    800d03 <strtol+0x57>
		s += 2, base = 16;
  800cf9:	83 c2 02             	add    $0x2,%edx
  800cfc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d01:	eb 12                	jmp    800d15 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d03:	85 db                	test   %ebx,%ebx
  800d05:	75 0e                	jne    800d15 <strtol+0x69>
  800d07:	3c 30                	cmp    $0x30,%al
  800d09:	75 05                	jne    800d10 <strtol+0x64>
		s++, base = 8;
  800d0b:	42                   	inc    %edx
  800d0c:	b3 08                	mov    $0x8,%bl
  800d0e:	eb 05                	jmp    800d15 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d10:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d15:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d1c:	8a 0a                	mov    (%edx),%cl
  800d1e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d21:	80 fb 09             	cmp    $0x9,%bl
  800d24:	77 08                	ja     800d2e <strtol+0x82>
			dig = *s - '0';
  800d26:	0f be c9             	movsbl %cl,%ecx
  800d29:	83 e9 30             	sub    $0x30,%ecx
  800d2c:	eb 1e                	jmp    800d4c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d2e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d31:	80 fb 19             	cmp    $0x19,%bl
  800d34:	77 08                	ja     800d3e <strtol+0x92>
			dig = *s - 'a' + 10;
  800d36:	0f be c9             	movsbl %cl,%ecx
  800d39:	83 e9 57             	sub    $0x57,%ecx
  800d3c:	eb 0e                	jmp    800d4c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d3e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d41:	80 fb 19             	cmp    $0x19,%bl
  800d44:	77 12                	ja     800d58 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d46:	0f be c9             	movsbl %cl,%ecx
  800d49:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d4c:	39 f1                	cmp    %esi,%ecx
  800d4e:	7d 0c                	jge    800d5c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d50:	42                   	inc    %edx
  800d51:	0f af c6             	imul   %esi,%eax
  800d54:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d56:	eb c4                	jmp    800d1c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d58:	89 c1                	mov    %eax,%ecx
  800d5a:	eb 02                	jmp    800d5e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d5c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d5e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d62:	74 05                	je     800d69 <strtol+0xbd>
		*endptr = (char *) s;
  800d64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d67:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d69:	85 ff                	test   %edi,%edi
  800d6b:	74 04                	je     800d71 <strtol+0xc5>
  800d6d:	89 c8                	mov    %ecx,%eax
  800d6f:	f7 d8                	neg    %eax
}
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5f                   	pop    %edi
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    
	...

00800d78 <__udivdi3>:
  800d78:	55                   	push   %ebp
  800d79:	57                   	push   %edi
  800d7a:	56                   	push   %esi
  800d7b:	83 ec 10             	sub    $0x10,%esp
  800d7e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d82:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d8a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800d8e:	89 cd                	mov    %ecx,%ebp
  800d90:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800d94:	85 c0                	test   %eax,%eax
  800d96:	75 2c                	jne    800dc4 <__udivdi3+0x4c>
  800d98:	39 f9                	cmp    %edi,%ecx
  800d9a:	77 68                	ja     800e04 <__udivdi3+0x8c>
  800d9c:	85 c9                	test   %ecx,%ecx
  800d9e:	75 0b                	jne    800dab <__udivdi3+0x33>
  800da0:	b8 01 00 00 00       	mov    $0x1,%eax
  800da5:	31 d2                	xor    %edx,%edx
  800da7:	f7 f1                	div    %ecx
  800da9:	89 c1                	mov    %eax,%ecx
  800dab:	31 d2                	xor    %edx,%edx
  800dad:	89 f8                	mov    %edi,%eax
  800daf:	f7 f1                	div    %ecx
  800db1:	89 c7                	mov    %eax,%edi
  800db3:	89 f0                	mov    %esi,%eax
  800db5:	f7 f1                	div    %ecx
  800db7:	89 c6                	mov    %eax,%esi
  800db9:	89 f0                	mov    %esi,%eax
  800dbb:	89 fa                	mov    %edi,%edx
  800dbd:	83 c4 10             	add    $0x10,%esp
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    
  800dc4:	39 f8                	cmp    %edi,%eax
  800dc6:	77 2c                	ja     800df4 <__udivdi3+0x7c>
  800dc8:	0f bd f0             	bsr    %eax,%esi
  800dcb:	83 f6 1f             	xor    $0x1f,%esi
  800dce:	75 4c                	jne    800e1c <__udivdi3+0xa4>
  800dd0:	39 f8                	cmp    %edi,%eax
  800dd2:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd7:	72 0a                	jb     800de3 <__udivdi3+0x6b>
  800dd9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800ddd:	0f 87 ad 00 00 00    	ja     800e90 <__udivdi3+0x118>
  800de3:	be 01 00 00 00       	mov    $0x1,%esi
  800de8:	89 f0                	mov    %esi,%eax
  800dea:	89 fa                	mov    %edi,%edx
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    
  800df3:	90                   	nop
  800df4:	31 ff                	xor    %edi,%edi
  800df6:	31 f6                	xor    %esi,%esi
  800df8:	89 f0                	mov    %esi,%eax
  800dfa:	89 fa                	mov    %edi,%edx
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    
  800e03:	90                   	nop
  800e04:	89 fa                	mov    %edi,%edx
  800e06:	89 f0                	mov    %esi,%eax
  800e08:	f7 f1                	div    %ecx
  800e0a:	89 c6                	mov    %eax,%esi
  800e0c:	31 ff                	xor    %edi,%edi
  800e0e:	89 f0                	mov    %esi,%eax
  800e10:	89 fa                	mov    %edi,%edx
  800e12:	83 c4 10             	add    $0x10,%esp
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    
  800e19:	8d 76 00             	lea    0x0(%esi),%esi
  800e1c:	89 f1                	mov    %esi,%ecx
  800e1e:	d3 e0                	shl    %cl,%eax
  800e20:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e24:	b8 20 00 00 00       	mov    $0x20,%eax
  800e29:	29 f0                	sub    %esi,%eax
  800e2b:	89 ea                	mov    %ebp,%edx
  800e2d:	88 c1                	mov    %al,%cl
  800e2f:	d3 ea                	shr    %cl,%edx
  800e31:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e35:	09 ca                	or     %ecx,%edx
  800e37:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e3b:	89 f1                	mov    %esi,%ecx
  800e3d:	d3 e5                	shl    %cl,%ebp
  800e3f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e43:	89 fd                	mov    %edi,%ebp
  800e45:	88 c1                	mov    %al,%cl
  800e47:	d3 ed                	shr    %cl,%ebp
  800e49:	89 fa                	mov    %edi,%edx
  800e4b:	89 f1                	mov    %esi,%ecx
  800e4d:	d3 e2                	shl    %cl,%edx
  800e4f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e53:	88 c1                	mov    %al,%cl
  800e55:	d3 ef                	shr    %cl,%edi
  800e57:	09 d7                	or     %edx,%edi
  800e59:	89 f8                	mov    %edi,%eax
  800e5b:	89 ea                	mov    %ebp,%edx
  800e5d:	f7 74 24 08          	divl   0x8(%esp)
  800e61:	89 d1                	mov    %edx,%ecx
  800e63:	89 c7                	mov    %eax,%edi
  800e65:	f7 64 24 0c          	mull   0xc(%esp)
  800e69:	39 d1                	cmp    %edx,%ecx
  800e6b:	72 17                	jb     800e84 <__udivdi3+0x10c>
  800e6d:	74 09                	je     800e78 <__udivdi3+0x100>
  800e6f:	89 fe                	mov    %edi,%esi
  800e71:	31 ff                	xor    %edi,%edi
  800e73:	e9 41 ff ff ff       	jmp    800db9 <__udivdi3+0x41>
  800e78:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e7c:	89 f1                	mov    %esi,%ecx
  800e7e:	d3 e2                	shl    %cl,%edx
  800e80:	39 c2                	cmp    %eax,%edx
  800e82:	73 eb                	jae    800e6f <__udivdi3+0xf7>
  800e84:	8d 77 ff             	lea    -0x1(%edi),%esi
  800e87:	31 ff                	xor    %edi,%edi
  800e89:	e9 2b ff ff ff       	jmp    800db9 <__udivdi3+0x41>
  800e8e:	66 90                	xchg   %ax,%ax
  800e90:	31 f6                	xor    %esi,%esi
  800e92:	e9 22 ff ff ff       	jmp    800db9 <__udivdi3+0x41>
	...

00800e98 <__umoddi3>:
  800e98:	55                   	push   %ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	83 ec 20             	sub    $0x20,%esp
  800e9e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ea2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800ea6:	89 44 24 14          	mov    %eax,0x14(%esp)
  800eaa:	8b 74 24 34          	mov    0x34(%esp),%esi
  800eae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800eb2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800eb6:	89 c7                	mov    %eax,%edi
  800eb8:	89 f2                	mov    %esi,%edx
  800eba:	85 ed                	test   %ebp,%ebp
  800ebc:	75 16                	jne    800ed4 <__umoddi3+0x3c>
  800ebe:	39 f1                	cmp    %esi,%ecx
  800ec0:	0f 86 a6 00 00 00    	jbe    800f6c <__umoddi3+0xd4>
  800ec6:	f7 f1                	div    %ecx
  800ec8:	89 d0                	mov    %edx,%eax
  800eca:	31 d2                	xor    %edx,%edx
  800ecc:	83 c4 20             	add    $0x20,%esp
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    
  800ed3:	90                   	nop
  800ed4:	39 f5                	cmp    %esi,%ebp
  800ed6:	0f 87 ac 00 00 00    	ja     800f88 <__umoddi3+0xf0>
  800edc:	0f bd c5             	bsr    %ebp,%eax
  800edf:	83 f0 1f             	xor    $0x1f,%eax
  800ee2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee6:	0f 84 a8 00 00 00    	je     800f94 <__umoddi3+0xfc>
  800eec:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ef0:	d3 e5                	shl    %cl,%ebp
  800ef2:	bf 20 00 00 00       	mov    $0x20,%edi
  800ef7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800efb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800eff:	89 f9                	mov    %edi,%ecx
  800f01:	d3 e8                	shr    %cl,%eax
  800f03:	09 e8                	or     %ebp,%eax
  800f05:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f09:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f0d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f11:	d3 e0                	shl    %cl,%eax
  800f13:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f17:	89 f2                	mov    %esi,%edx
  800f19:	d3 e2                	shl    %cl,%edx
  800f1b:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f1f:	d3 e0                	shl    %cl,%eax
  800f21:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f25:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f29:	89 f9                	mov    %edi,%ecx
  800f2b:	d3 e8                	shr    %cl,%eax
  800f2d:	09 d0                	or     %edx,%eax
  800f2f:	d3 ee                	shr    %cl,%esi
  800f31:	89 f2                	mov    %esi,%edx
  800f33:	f7 74 24 18          	divl   0x18(%esp)
  800f37:	89 d6                	mov    %edx,%esi
  800f39:	f7 64 24 0c          	mull   0xc(%esp)
  800f3d:	89 c5                	mov    %eax,%ebp
  800f3f:	89 d1                	mov    %edx,%ecx
  800f41:	39 d6                	cmp    %edx,%esi
  800f43:	72 67                	jb     800fac <__umoddi3+0x114>
  800f45:	74 75                	je     800fbc <__umoddi3+0x124>
  800f47:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f4b:	29 e8                	sub    %ebp,%eax
  800f4d:	19 ce                	sbb    %ecx,%esi
  800f4f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f53:	d3 e8                	shr    %cl,%eax
  800f55:	89 f2                	mov    %esi,%edx
  800f57:	89 f9                	mov    %edi,%ecx
  800f59:	d3 e2                	shl    %cl,%edx
  800f5b:	09 d0                	or     %edx,%eax
  800f5d:	89 f2                	mov    %esi,%edx
  800f5f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f63:	d3 ea                	shr    %cl,%edx
  800f65:	83 c4 20             	add    $0x20,%esp
  800f68:	5e                   	pop    %esi
  800f69:	5f                   	pop    %edi
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    
  800f6c:	85 c9                	test   %ecx,%ecx
  800f6e:	75 0b                	jne    800f7b <__umoddi3+0xe3>
  800f70:	b8 01 00 00 00       	mov    $0x1,%eax
  800f75:	31 d2                	xor    %edx,%edx
  800f77:	f7 f1                	div    %ecx
  800f79:	89 c1                	mov    %eax,%ecx
  800f7b:	89 f0                	mov    %esi,%eax
  800f7d:	31 d2                	xor    %edx,%edx
  800f7f:	f7 f1                	div    %ecx
  800f81:	89 f8                	mov    %edi,%eax
  800f83:	e9 3e ff ff ff       	jmp    800ec6 <__umoddi3+0x2e>
  800f88:	89 f2                	mov    %esi,%edx
  800f8a:	83 c4 20             	add    $0x20,%esp
  800f8d:	5e                   	pop    %esi
  800f8e:	5f                   	pop    %edi
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    
  800f91:	8d 76 00             	lea    0x0(%esi),%esi
  800f94:	39 f5                	cmp    %esi,%ebp
  800f96:	72 04                	jb     800f9c <__umoddi3+0x104>
  800f98:	39 f9                	cmp    %edi,%ecx
  800f9a:	77 06                	ja     800fa2 <__umoddi3+0x10a>
  800f9c:	89 f2                	mov    %esi,%edx
  800f9e:	29 cf                	sub    %ecx,%edi
  800fa0:	19 ea                	sbb    %ebp,%edx
  800fa2:	89 f8                	mov    %edi,%eax
  800fa4:	83 c4 20             	add    $0x20,%esp
  800fa7:	5e                   	pop    %esi
  800fa8:	5f                   	pop    %edi
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    
  800fab:	90                   	nop
  800fac:	89 d1                	mov    %edx,%ecx
  800fae:	89 c5                	mov    %eax,%ebp
  800fb0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fb4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fb8:	eb 8d                	jmp    800f47 <__umoddi3+0xaf>
  800fba:	66 90                	xchg   %ax,%ax
  800fbc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fc0:	72 ea                	jb     800fac <__umoddi3+0x114>
  800fc2:	89 f1                	mov    %esi,%ecx
  800fc4:	eb 81                	jmp    800f47 <__umoddi3+0xaf>

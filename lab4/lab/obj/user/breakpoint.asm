
obj/user/breakpoint:     file format elf32-i386


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
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    
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
  80004a:	e8 e4 00 00 00       	call   800133 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80004f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800054:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80005b:	c1 e0 07             	shl    $0x7,%eax
  80005e:	29 d0                	sub    %edx,%eax
  800060:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800065:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 f6                	test   %esi,%esi
  80006c:	7e 07                	jle    800075 <libmain+0x39>
		binaryname = argv[0];
  80006e:	8b 03                	mov    (%ebx),%eax
  800070:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  800096:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009d:	e8 3f 00 00 00       	call   8000e1 <sys_env_destroy>
}
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8000af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b5:	89 c3                	mov    %eax,%ebx
  8000b7:	89 c7                	mov    %eax,%edi
  8000b9:	89 c6                	mov    %eax,%esi
  8000bb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5f                   	pop    %edi
  8000c0:	5d                   	pop    %ebp
  8000c1:	c3                   	ret    

008000c2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d2:	89 d1                	mov    %edx,%ecx
  8000d4:	89 d3                	mov    %edx,%ebx
  8000d6:	89 d7                	mov    %edx,%edi
  8000d8:	89 d6                	mov    %edx,%esi
  8000da:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f7:	89 cb                	mov    %ecx,%ebx
  8000f9:	89 cf                	mov    %ecx,%edi
  8000fb:	89 ce                	mov    %ecx,%esi
  8000fd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000ff:	85 c0                	test   %eax,%eax
  800101:	7e 28                	jle    80012b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800103:	89 44 24 10          	mov    %eax,0x10(%esp)
  800107:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80010e:	00 
  80010f:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  800116:	00 
  800117:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011e:	00 
  80011f:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800126:	e8 5d 02 00 00       	call   800388 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012b:	83 c4 2c             	add    $0x2c,%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	57                   	push   %edi
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800139:	ba 00 00 00 00       	mov    $0x0,%edx
  80013e:	b8 02 00 00 00       	mov    $0x2,%eax
  800143:	89 d1                	mov    %edx,%ecx
  800145:	89 d3                	mov    %edx,%ebx
  800147:	89 d7                	mov    %edx,%edi
  800149:	89 d6                	mov    %edx,%esi
  80014b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5f                   	pop    %edi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    

00800152 <sys_yield>:

void
sys_yield(void)
{
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	57                   	push   %edi
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800158:	ba 00 00 00 00       	mov    $0x0,%edx
  80015d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800162:	89 d1                	mov    %edx,%ecx
  800164:	89 d3                	mov    %edx,%ebx
  800166:	89 d7                	mov    %edx,%edi
  800168:	89 d6                	mov    %edx,%esi
  80016a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016c:	5b                   	pop    %ebx
  80016d:	5e                   	pop    %esi
  80016e:	5f                   	pop    %edi
  80016f:	5d                   	pop    %ebp
  800170:	c3                   	ret    

00800171 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	57                   	push   %edi
  800175:	56                   	push   %esi
  800176:	53                   	push   %ebx
  800177:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017a:	be 00 00 00 00       	mov    $0x0,%esi
  80017f:	b8 04 00 00 00       	mov    $0x4,%eax
  800184:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800187:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018a:	8b 55 08             	mov    0x8(%ebp),%edx
  80018d:	89 f7                	mov    %esi,%edi
  80018f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800191:	85 c0                	test   %eax,%eax
  800193:	7e 28                	jle    8001bd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800195:	89 44 24 10          	mov    %eax,0x10(%esp)
  800199:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001a0:	00 
  8001a1:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8001a8:	00 
  8001a9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b0:	00 
  8001b1:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  8001b8:	e8 cb 01 00 00       	call   800388 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bd:	83 c4 2c             	add    $0x2c,%esp
  8001c0:	5b                   	pop    %ebx
  8001c1:	5e                   	pop    %esi
  8001c2:	5f                   	pop    %edi
  8001c3:	5d                   	pop    %ebp
  8001c4:	c3                   	ret    

008001c5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ce:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001df:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e4:	85 c0                	test   %eax,%eax
  8001e6:	7e 28                	jle    800210 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ec:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001f3:	00 
  8001f4:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8001fb:	00 
  8001fc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800203:	00 
  800204:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80020b:	e8 78 01 00 00       	call   800388 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800210:	83 c4 2c             	add    $0x2c,%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5f                   	pop    %edi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    

00800218 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800221:	bb 00 00 00 00       	mov    $0x0,%ebx
  800226:	b8 06 00 00 00       	mov    $0x6,%eax
  80022b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022e:	8b 55 08             	mov    0x8(%ebp),%edx
  800231:	89 df                	mov    %ebx,%edi
  800233:	89 de                	mov    %ebx,%esi
  800235:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800237:	85 c0                	test   %eax,%eax
  800239:	7e 28                	jle    800263 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80023f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800246:	00 
  800247:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  80024e:	00 
  80024f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800256:	00 
  800257:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80025e:	e8 25 01 00 00       	call   800388 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800263:	83 c4 2c             	add    $0x2c,%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800274:	bb 00 00 00 00       	mov    $0x0,%ebx
  800279:	b8 08 00 00 00       	mov    $0x8,%eax
  80027e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800281:	8b 55 08             	mov    0x8(%ebp),%edx
  800284:	89 df                	mov    %ebx,%edi
  800286:	89 de                	mov    %ebx,%esi
  800288:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028a:	85 c0                	test   %eax,%eax
  80028c:	7e 28                	jle    8002b6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800292:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800299:	00 
  80029a:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8002a1:	00 
  8002a2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a9:	00 
  8002aa:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  8002b1:	e8 d2 00 00 00       	call   800388 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002b6:	83 c4 2c             	add    $0x2c,%esp
  8002b9:	5b                   	pop    %ebx
  8002ba:	5e                   	pop    %esi
  8002bb:	5f                   	pop    %edi
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	57                   	push   %edi
  8002c2:	56                   	push   %esi
  8002c3:	53                   	push   %ebx
  8002c4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cc:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d7:	89 df                	mov    %ebx,%edi
  8002d9:	89 de                	mov    %ebx,%esi
  8002db:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002dd:	85 c0                	test   %eax,%eax
  8002df:	7e 28                	jle    800309 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002ec:	00 
  8002ed:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8002f4:	00 
  8002f5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002fc:	00 
  8002fd:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800304:	e8 7f 00 00 00       	call   800388 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800309:	83 c4 2c             	add    $0x2c,%esp
  80030c:	5b                   	pop    %ebx
  80030d:	5e                   	pop    %esi
  80030e:	5f                   	pop    %edi
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	57                   	push   %edi
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800317:	be 00 00 00 00       	mov    $0x0,%esi
  80031c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800321:	8b 7d 14             	mov    0x14(%ebp),%edi
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032a:	8b 55 08             	mov    0x8(%ebp),%edx
  80032d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032f:	5b                   	pop    %ebx
  800330:	5e                   	pop    %esi
  800331:	5f                   	pop    %edi
  800332:	5d                   	pop    %ebp
  800333:	c3                   	ret    

00800334 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	57                   	push   %edi
  800338:	56                   	push   %esi
  800339:	53                   	push   %ebx
  80033a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800342:	b8 0c 00 00 00       	mov    $0xc,%eax
  800347:	8b 55 08             	mov    0x8(%ebp),%edx
  80034a:	89 cb                	mov    %ecx,%ebx
  80034c:	89 cf                	mov    %ecx,%edi
  80034e:	89 ce                	mov    %ecx,%esi
  800350:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800352:	85 c0                	test   %eax,%eax
  800354:	7e 28                	jle    80037e <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800356:	89 44 24 10          	mov    %eax,0x10(%esp)
  80035a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800361:	00 
  800362:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  800369:	00 
  80036a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800371:	00 
  800372:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800379:	e8 0a 00 00 00       	call   800388 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80037e:	83 c4 2c             	add    $0x2c,%esp
  800381:	5b                   	pop    %ebx
  800382:	5e                   	pop    %esi
  800383:	5f                   	pop    %edi
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    
	...

00800388 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	56                   	push   %esi
  80038c:	53                   	push   %ebx
  80038d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800390:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800393:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800399:	e8 95 fd ff ff       	call   800133 <sys_getenvid>
  80039e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b4:	c7 04 24 f8 0f 80 00 	movl   $0x800ff8,(%esp)
  8003bb:	e8 c0 00 00 00       	call   800480 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c7:	89 04 24             	mov    %eax,(%esp)
  8003ca:	e8 50 00 00 00       	call   80041f <vcprintf>
	cprintf("\n");
  8003cf:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  8003d6:	e8 a5 00 00 00       	call   800480 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003db:	cc                   	int3   
  8003dc:	eb fd                	jmp    8003db <_panic+0x53>
	...

008003e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	53                   	push   %ebx
  8003e4:	83 ec 14             	sub    $0x14,%esp
  8003e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ea:	8b 03                	mov    (%ebx),%eax
  8003ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ef:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003f3:	40                   	inc    %eax
  8003f4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003fb:	75 19                	jne    800416 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003fd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800404:	00 
  800405:	8d 43 08             	lea    0x8(%ebx),%eax
  800408:	89 04 24             	mov    %eax,(%esp)
  80040b:	e8 94 fc ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  800410:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800416:	ff 43 04             	incl   0x4(%ebx)
}
  800419:	83 c4 14             	add    $0x14,%esp
  80041c:	5b                   	pop    %ebx
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800428:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80042f:	00 00 00 
	b.cnt = 0;
  800432:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800439:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80043c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800443:	8b 45 08             	mov    0x8(%ebp),%eax
  800446:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800450:	89 44 24 04          	mov    %eax,0x4(%esp)
  800454:	c7 04 24 e0 03 80 00 	movl   $0x8003e0,(%esp)
  80045b:	e8 82 01 00 00       	call   8005e2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800460:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800466:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	e8 2c fc ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  800478:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800486:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048d:	8b 45 08             	mov    0x8(%ebp),%eax
  800490:	89 04 24             	mov    %eax,(%esp)
  800493:	e8 87 ff ff ff       	call   80041f <vcprintf>
	va_end(ap);

	return cnt;
}
  800498:	c9                   	leave  
  800499:	c3                   	ret    
	...

0080049c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	57                   	push   %edi
  8004a0:	56                   	push   %esi
  8004a1:	53                   	push   %ebx
  8004a2:	83 ec 3c             	sub    $0x3c,%esp
  8004a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a8:	89 d7                	mov    %edx,%edi
  8004aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004b9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	75 08                	jne    8004c8 <printnum+0x2c>
  8004c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004c6:	77 57                	ja     80051f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004cc:	4b                   	dec    %ebx
  8004cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004dc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004e7:	00 
  8004e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004eb:	89 04 24             	mov    %eax,(%esp)
  8004ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f5:	e8 76 08 00 00       	call   800d70 <__udivdi3>
  8004fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004fe:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800502:	89 04 24             	mov    %eax,(%esp)
  800505:	89 54 24 04          	mov    %edx,0x4(%esp)
  800509:	89 fa                	mov    %edi,%edx
  80050b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050e:	e8 89 ff ff ff       	call   80049c <printnum>
  800513:	eb 0f                	jmp    800524 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800515:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800519:	89 34 24             	mov    %esi,(%esp)
  80051c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80051f:	4b                   	dec    %ebx
  800520:	85 db                	test   %ebx,%ebx
  800522:	7f f1                	jg     800515 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800524:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800528:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80052c:	8b 45 10             	mov    0x10(%ebp),%eax
  80052f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800533:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80053a:	00 
  80053b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800544:	89 44 24 04          	mov    %eax,0x4(%esp)
  800548:	e8 43 09 00 00       	call   800e90 <__umoddi3>
  80054d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800551:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  800558:	89 04 24             	mov    %eax,(%esp)
  80055b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80055e:	83 c4 3c             	add    $0x3c,%esp
  800561:	5b                   	pop    %ebx
  800562:	5e                   	pop    %esi
  800563:	5f                   	pop    %edi
  800564:	5d                   	pop    %ebp
  800565:	c3                   	ret    

00800566 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800566:	55                   	push   %ebp
  800567:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800569:	83 fa 01             	cmp    $0x1,%edx
  80056c:	7e 0e                	jle    80057c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80056e:	8b 10                	mov    (%eax),%edx
  800570:	8d 4a 08             	lea    0x8(%edx),%ecx
  800573:	89 08                	mov    %ecx,(%eax)
  800575:	8b 02                	mov    (%edx),%eax
  800577:	8b 52 04             	mov    0x4(%edx),%edx
  80057a:	eb 22                	jmp    80059e <getuint+0x38>
	else if (lflag)
  80057c:	85 d2                	test   %edx,%edx
  80057e:	74 10                	je     800590 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800580:	8b 10                	mov    (%eax),%edx
  800582:	8d 4a 04             	lea    0x4(%edx),%ecx
  800585:	89 08                	mov    %ecx,(%eax)
  800587:	8b 02                	mov    (%edx),%eax
  800589:	ba 00 00 00 00       	mov    $0x0,%edx
  80058e:	eb 0e                	jmp    80059e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800590:	8b 10                	mov    (%eax),%edx
  800592:	8d 4a 04             	lea    0x4(%edx),%ecx
  800595:	89 08                	mov    %ecx,(%eax)
  800597:	8b 02                	mov    (%edx),%eax
  800599:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80059e:	5d                   	pop    %ebp
  80059f:	c3                   	ret    

008005a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005a0:	55                   	push   %ebp
  8005a1:	89 e5                	mov    %esp,%ebp
  8005a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005a6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005a9:	8b 10                	mov    (%eax),%edx
  8005ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ae:	73 08                	jae    8005b8 <sprintputch+0x18>
		*b->buf++ = ch;
  8005b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005b3:	88 0a                	mov    %cl,(%edx)
  8005b5:	42                   	inc    %edx
  8005b6:	89 10                	mov    %edx,(%eax)
}
  8005b8:	5d                   	pop    %ebp
  8005b9:	c3                   	ret    

008005ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ba:	55                   	push   %ebp
  8005bb:	89 e5                	mov    %esp,%ebp
  8005bd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d8:	89 04 24             	mov    %eax,(%esp)
  8005db:	e8 02 00 00 00       	call   8005e2 <vprintfmt>
	va_end(ap);
}
  8005e0:	c9                   	leave  
  8005e1:	c3                   	ret    

008005e2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005e2:	55                   	push   %ebp
  8005e3:	89 e5                	mov    %esp,%ebp
  8005e5:	57                   	push   %edi
  8005e6:	56                   	push   %esi
  8005e7:	53                   	push   %ebx
  8005e8:	83 ec 4c             	sub    $0x4c,%esp
  8005eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8005f1:	eb 12                	jmp    800605 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	0f 84 8b 03 00 00    	je     800986 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8005fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800605:	0f b6 06             	movzbl (%esi),%eax
  800608:	46                   	inc    %esi
  800609:	83 f8 25             	cmp    $0x25,%eax
  80060c:	75 e5                	jne    8005f3 <vprintfmt+0x11>
  80060e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800612:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800619:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80061e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800625:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062a:	eb 26                	jmp    800652 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80062f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800633:	eb 1d                	jmp    800652 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800638:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80063c:	eb 14                	jmp    800652 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800641:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800648:	eb 08                	jmp    800652 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80064a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80064d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	0f b6 06             	movzbl (%esi),%eax
  800655:	8d 56 01             	lea    0x1(%esi),%edx
  800658:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80065b:	8a 16                	mov    (%esi),%dl
  80065d:	83 ea 23             	sub    $0x23,%edx
  800660:	80 fa 55             	cmp    $0x55,%dl
  800663:	0f 87 01 03 00 00    	ja     80096a <vprintfmt+0x388>
  800669:	0f b6 d2             	movzbl %dl,%edx
  80066c:	ff 24 95 e0 10 80 00 	jmp    *0x8010e0(,%edx,4)
  800673:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800676:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80067b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80067e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800682:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800685:	8d 50 d0             	lea    -0x30(%eax),%edx
  800688:	83 fa 09             	cmp    $0x9,%edx
  80068b:	77 2a                	ja     8006b7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80068d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80068e:	eb eb                	jmp    80067b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 50 04             	lea    0x4(%eax),%edx
  800696:	89 55 14             	mov    %edx,0x14(%ebp)
  800699:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80069e:	eb 17                	jmp    8006b7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a4:	78 98                	js     80063e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a9:	eb a7                	jmp    800652 <vprintfmt+0x70>
  8006ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006ae:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006b5:	eb 9b                	jmp    800652 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006bb:	79 95                	jns    800652 <vprintfmt+0x70>
  8006bd:	eb 8b                	jmp    80064a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006bf:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006c3:	eb 8d                	jmp    800652 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8d 50 04             	lea    0x4(%eax),%edx
  8006cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	89 04 24             	mov    %eax,(%esp)
  8006d7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006da:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006dd:	e9 23 ff ff ff       	jmp    800605 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 50 04             	lea    0x4(%eax),%edx
  8006e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006eb:	8b 00                	mov    (%eax),%eax
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	79 02                	jns    8006f3 <vprintfmt+0x111>
  8006f1:	f7 d8                	neg    %eax
  8006f3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f5:	83 f8 08             	cmp    $0x8,%eax
  8006f8:	7f 0b                	jg     800705 <vprintfmt+0x123>
  8006fa:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  800701:	85 c0                	test   %eax,%eax
  800703:	75 23                	jne    800728 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800705:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800709:	c7 44 24 08 36 10 80 	movl   $0x801036,0x8(%esp)
  800710:	00 
  800711:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	89 04 24             	mov    %eax,(%esp)
  80071b:	e8 9a fe ff ff       	call   8005ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800720:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800723:	e9 dd fe ff ff       	jmp    800605 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800728:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072c:	c7 44 24 08 3f 10 80 	movl   $0x80103f,0x8(%esp)
  800733:	00 
  800734:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800738:	8b 55 08             	mov    0x8(%ebp),%edx
  80073b:	89 14 24             	mov    %edx,(%esp)
  80073e:	e8 77 fe ff ff       	call   8005ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800743:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800746:	e9 ba fe ff ff       	jmp    800605 <vprintfmt+0x23>
  80074b:	89 f9                	mov    %edi,%ecx
  80074d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800750:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8d 50 04             	lea    0x4(%eax),%edx
  800759:	89 55 14             	mov    %edx,0x14(%ebp)
  80075c:	8b 30                	mov    (%eax),%esi
  80075e:	85 f6                	test   %esi,%esi
  800760:	75 05                	jne    800767 <vprintfmt+0x185>
				p = "(null)";
  800762:	be 2f 10 80 00       	mov    $0x80102f,%esi
			if (width > 0 && padc != '-')
  800767:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80076b:	0f 8e 84 00 00 00    	jle    8007f5 <vprintfmt+0x213>
  800771:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800775:	74 7e                	je     8007f5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800777:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80077b:	89 34 24             	mov    %esi,(%esp)
  80077e:	e8 ab 02 00 00       	call   800a2e <strnlen>
  800783:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800786:	29 c2                	sub    %eax,%edx
  800788:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80078b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80078f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800792:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800795:	89 de                	mov    %ebx,%esi
  800797:	89 d3                	mov    %edx,%ebx
  800799:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80079b:	eb 0b                	jmp    8007a8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80079d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a1:	89 3c 24             	mov    %edi,(%esp)
  8007a4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a7:	4b                   	dec    %ebx
  8007a8:	85 db                	test   %ebx,%ebx
  8007aa:	7f f1                	jg     80079d <vprintfmt+0x1bb>
  8007ac:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007af:	89 f3                	mov    %esi,%ebx
  8007b1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007b7:	85 c0                	test   %eax,%eax
  8007b9:	79 05                	jns    8007c0 <vprintfmt+0x1de>
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007c3:	29 c2                	sub    %eax,%edx
  8007c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007c8:	eb 2b                	jmp    8007f5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007ca:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007ce:	74 18                	je     8007e8 <vprintfmt+0x206>
  8007d0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007d3:	83 fa 5e             	cmp    $0x5e,%edx
  8007d6:	76 10                	jbe    8007e8 <vprintfmt+0x206>
					putch('?', putdat);
  8007d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007dc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007e3:	ff 55 08             	call   *0x8(%ebp)
  8007e6:	eb 0a                	jmp    8007f2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ec:	89 04 24             	mov    %eax,(%esp)
  8007ef:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f2:	ff 4d e4             	decl   -0x1c(%ebp)
  8007f5:	0f be 06             	movsbl (%esi),%eax
  8007f8:	46                   	inc    %esi
  8007f9:	85 c0                	test   %eax,%eax
  8007fb:	74 21                	je     80081e <vprintfmt+0x23c>
  8007fd:	85 ff                	test   %edi,%edi
  8007ff:	78 c9                	js     8007ca <vprintfmt+0x1e8>
  800801:	4f                   	dec    %edi
  800802:	79 c6                	jns    8007ca <vprintfmt+0x1e8>
  800804:	8b 7d 08             	mov    0x8(%ebp),%edi
  800807:	89 de                	mov    %ebx,%esi
  800809:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80080c:	eb 18                	jmp    800826 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80080e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800812:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800819:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80081b:	4b                   	dec    %ebx
  80081c:	eb 08                	jmp    800826 <vprintfmt+0x244>
  80081e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800821:	89 de                	mov    %ebx,%esi
  800823:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800826:	85 db                	test   %ebx,%ebx
  800828:	7f e4                	jg     80080e <vprintfmt+0x22c>
  80082a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80082d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800832:	e9 ce fd ff ff       	jmp    800605 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800837:	83 f9 01             	cmp    $0x1,%ecx
  80083a:	7e 10                	jle    80084c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8d 50 08             	lea    0x8(%eax),%edx
  800842:	89 55 14             	mov    %edx,0x14(%ebp)
  800845:	8b 30                	mov    (%eax),%esi
  800847:	8b 78 04             	mov    0x4(%eax),%edi
  80084a:	eb 26                	jmp    800872 <vprintfmt+0x290>
	else if (lflag)
  80084c:	85 c9                	test   %ecx,%ecx
  80084e:	74 12                	je     800862 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8d 50 04             	lea    0x4(%eax),%edx
  800856:	89 55 14             	mov    %edx,0x14(%ebp)
  800859:	8b 30                	mov    (%eax),%esi
  80085b:	89 f7                	mov    %esi,%edi
  80085d:	c1 ff 1f             	sar    $0x1f,%edi
  800860:	eb 10                	jmp    800872 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800862:	8b 45 14             	mov    0x14(%ebp),%eax
  800865:	8d 50 04             	lea    0x4(%eax),%edx
  800868:	89 55 14             	mov    %edx,0x14(%ebp)
  80086b:	8b 30                	mov    (%eax),%esi
  80086d:	89 f7                	mov    %esi,%edi
  80086f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800872:	85 ff                	test   %edi,%edi
  800874:	78 0a                	js     800880 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800876:	b8 0a 00 00 00       	mov    $0xa,%eax
  80087b:	e9 ac 00 00 00       	jmp    80092c <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800880:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800884:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80088b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80088e:	f7 de                	neg    %esi
  800890:	83 d7 00             	adc    $0x0,%edi
  800893:	f7 df                	neg    %edi
			}
			base = 10;
  800895:	b8 0a 00 00 00       	mov    $0xa,%eax
  80089a:	e9 8d 00 00 00       	jmp    80092c <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80089f:	89 ca                	mov    %ecx,%edx
  8008a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a4:	e8 bd fc ff ff       	call   800566 <getuint>
  8008a9:	89 c6                	mov    %eax,%esi
  8008ab:	89 d7                	mov    %edx,%edi
			base = 10;
  8008ad:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008b2:	eb 78                	jmp    80092c <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8008b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008bf:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8008c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c6:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008cd:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8008d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d4:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008db:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008de:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8008e1:	e9 1f fd ff ff       	jmp    800605 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8008e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ea:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008f1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008ff:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800902:	8b 45 14             	mov    0x14(%ebp),%eax
  800905:	8d 50 04             	lea    0x4(%eax),%edx
  800908:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80090b:	8b 30                	mov    (%eax),%esi
  80090d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800912:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800917:	eb 13                	jmp    80092c <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800919:	89 ca                	mov    %ecx,%edx
  80091b:	8d 45 14             	lea    0x14(%ebp),%eax
  80091e:	e8 43 fc ff ff       	call   800566 <getuint>
  800923:	89 c6                	mov    %eax,%esi
  800925:	89 d7                	mov    %edx,%edi
			base = 16;
  800927:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80092c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800930:	89 54 24 10          	mov    %edx,0x10(%esp)
  800934:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800937:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80093b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80093f:	89 34 24             	mov    %esi,(%esp)
  800942:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800946:	89 da                	mov    %ebx,%edx
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	e8 4c fb ff ff       	call   80049c <printnum>
			break;
  800950:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800953:	e9 ad fc ff ff       	jmp    800605 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800958:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095c:	89 04 24             	mov    %eax,(%esp)
  80095f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800962:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800965:	e9 9b fc ff ff       	jmp    800605 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80096a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80096e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800975:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800978:	eb 01                	jmp    80097b <vprintfmt+0x399>
  80097a:	4e                   	dec    %esi
  80097b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80097f:	75 f9                	jne    80097a <vprintfmt+0x398>
  800981:	e9 7f fc ff ff       	jmp    800605 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800986:	83 c4 4c             	add    $0x4c,%esp
  800989:	5b                   	pop    %ebx
  80098a:	5e                   	pop    %esi
  80098b:	5f                   	pop    %edi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	83 ec 28             	sub    $0x28,%esp
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80099a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80099d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009a1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ab:	85 c0                	test   %eax,%eax
  8009ad:	74 30                	je     8009df <vsnprintf+0x51>
  8009af:	85 d2                	test   %edx,%edx
  8009b1:	7e 33                	jle    8009e6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8009bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c8:	c7 04 24 a0 05 80 00 	movl   $0x8005a0,(%esp)
  8009cf:	e8 0e fc ff ff       	call   8005e2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009dd:	eb 0c                	jmp    8009eb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009e4:	eb 05                	jmp    8009eb <vsnprintf+0x5d>
  8009e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009f3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	89 04 24             	mov    %eax,(%esp)
  800a0e:	e8 7b ff ff ff       	call   80098e <vsnprintf>
	va_end(ap);

	return rc;
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    
  800a15:	00 00                	add    %al,(%eax)
	...

00800a18 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a23:	eb 01                	jmp    800a26 <strlen+0xe>
		n++;
  800a25:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a26:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a2a:	75 f9                	jne    800a25 <strlen+0xd>
		n++;
	return n;
}
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a34:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3c:	eb 01                	jmp    800a3f <strnlen+0x11>
		n++;
  800a3e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a3f:	39 d0                	cmp    %edx,%eax
  800a41:	74 06                	je     800a49 <strnlen+0x1b>
  800a43:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a47:	75 f5                	jne    800a3e <strnlen+0x10>
		n++;
	return n;
}
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	53                   	push   %ebx
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a55:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a5d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a60:	42                   	inc    %edx
  800a61:	84 c9                	test   %cl,%cl
  800a63:	75 f5                	jne    800a5a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a65:	5b                   	pop    %ebx
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	53                   	push   %ebx
  800a6c:	83 ec 08             	sub    $0x8,%esp
  800a6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a72:	89 1c 24             	mov    %ebx,(%esp)
  800a75:	e8 9e ff ff ff       	call   800a18 <strlen>
	strcpy(dst + len, src);
  800a7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a81:	01 d8                	add    %ebx,%eax
  800a83:	89 04 24             	mov    %eax,(%esp)
  800a86:	e8 c0 ff ff ff       	call   800a4b <strcpy>
	return dst;
}
  800a8b:	89 d8                	mov    %ebx,%eax
  800a8d:	83 c4 08             	add    $0x8,%esp
  800a90:	5b                   	pop    %ebx
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa6:	eb 0c                	jmp    800ab4 <strncpy+0x21>
		*dst++ = *src;
  800aa8:	8a 1a                	mov    (%edx),%bl
  800aaa:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aad:	80 3a 01             	cmpb   $0x1,(%edx)
  800ab0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab3:	41                   	inc    %ecx
  800ab4:	39 f1                	cmp    %esi,%ecx
  800ab6:	75 f0                	jne    800aa8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aca:	85 d2                	test   %edx,%edx
  800acc:	75 0a                	jne    800ad8 <strlcpy+0x1c>
  800ace:	89 f0                	mov    %esi,%eax
  800ad0:	eb 1a                	jmp    800aec <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ad2:	88 18                	mov    %bl,(%eax)
  800ad4:	40                   	inc    %eax
  800ad5:	41                   	inc    %ecx
  800ad6:	eb 02                	jmp    800ada <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ad8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800ada:	4a                   	dec    %edx
  800adb:	74 0a                	je     800ae7 <strlcpy+0x2b>
  800add:	8a 19                	mov    (%ecx),%bl
  800adf:	84 db                	test   %bl,%bl
  800ae1:	75 ef                	jne    800ad2 <strlcpy+0x16>
  800ae3:	89 c2                	mov    %eax,%edx
  800ae5:	eb 02                	jmp    800ae9 <strlcpy+0x2d>
  800ae7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ae9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800aec:	29 f0                	sub    %esi,%eax
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800afb:	eb 02                	jmp    800aff <strcmp+0xd>
		p++, q++;
  800afd:	41                   	inc    %ecx
  800afe:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aff:	8a 01                	mov    (%ecx),%al
  800b01:	84 c0                	test   %al,%al
  800b03:	74 04                	je     800b09 <strcmp+0x17>
  800b05:	3a 02                	cmp    (%edx),%al
  800b07:	74 f4                	je     800afd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b09:	0f b6 c0             	movzbl %al,%eax
  800b0c:	0f b6 12             	movzbl (%edx),%edx
  800b0f:	29 d0                	sub    %edx,%eax
}
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	53                   	push   %ebx
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b20:	eb 03                	jmp    800b25 <strncmp+0x12>
		n--, p++, q++;
  800b22:	4a                   	dec    %edx
  800b23:	40                   	inc    %eax
  800b24:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b25:	85 d2                	test   %edx,%edx
  800b27:	74 14                	je     800b3d <strncmp+0x2a>
  800b29:	8a 18                	mov    (%eax),%bl
  800b2b:	84 db                	test   %bl,%bl
  800b2d:	74 04                	je     800b33 <strncmp+0x20>
  800b2f:	3a 19                	cmp    (%ecx),%bl
  800b31:	74 ef                	je     800b22 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b33:	0f b6 00             	movzbl (%eax),%eax
  800b36:	0f b6 11             	movzbl (%ecx),%edx
  800b39:	29 d0                	sub    %edx,%eax
  800b3b:	eb 05                	jmp    800b42 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b3d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b42:	5b                   	pop    %ebx
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b4e:	eb 05                	jmp    800b55 <strchr+0x10>
		if (*s == c)
  800b50:	38 ca                	cmp    %cl,%dl
  800b52:	74 0c                	je     800b60 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b54:	40                   	inc    %eax
  800b55:	8a 10                	mov    (%eax),%dl
  800b57:	84 d2                	test   %dl,%dl
  800b59:	75 f5                	jne    800b50 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b6b:	eb 05                	jmp    800b72 <strfind+0x10>
		if (*s == c)
  800b6d:	38 ca                	cmp    %cl,%dl
  800b6f:	74 07                	je     800b78 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b71:	40                   	inc    %eax
  800b72:	8a 10                	mov    (%eax),%dl
  800b74:	84 d2                	test   %dl,%dl
  800b76:	75 f5                	jne    800b6d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
  800b80:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b86:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b89:	85 c9                	test   %ecx,%ecx
  800b8b:	74 30                	je     800bbd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b8d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b93:	75 25                	jne    800bba <memset+0x40>
  800b95:	f6 c1 03             	test   $0x3,%cl
  800b98:	75 20                	jne    800bba <memset+0x40>
		c &= 0xFF;
  800b9a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b9d:	89 d3                	mov    %edx,%ebx
  800b9f:	c1 e3 08             	shl    $0x8,%ebx
  800ba2:	89 d6                	mov    %edx,%esi
  800ba4:	c1 e6 18             	shl    $0x18,%esi
  800ba7:	89 d0                	mov    %edx,%eax
  800ba9:	c1 e0 10             	shl    $0x10,%eax
  800bac:	09 f0                	or     %esi,%eax
  800bae:	09 d0                	or     %edx,%eax
  800bb0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bb2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bb5:	fc                   	cld    
  800bb6:	f3 ab                	rep stos %eax,%es:(%edi)
  800bb8:	eb 03                	jmp    800bbd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bba:	fc                   	cld    
  800bbb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bbd:	89 f8                	mov    %edi,%eax
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bd2:	39 c6                	cmp    %eax,%esi
  800bd4:	73 34                	jae    800c0a <memmove+0x46>
  800bd6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bd9:	39 d0                	cmp    %edx,%eax
  800bdb:	73 2d                	jae    800c0a <memmove+0x46>
		s += n;
		d += n;
  800bdd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be0:	f6 c2 03             	test   $0x3,%dl
  800be3:	75 1b                	jne    800c00 <memmove+0x3c>
  800be5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800beb:	75 13                	jne    800c00 <memmove+0x3c>
  800bed:	f6 c1 03             	test   $0x3,%cl
  800bf0:	75 0e                	jne    800c00 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bf2:	83 ef 04             	sub    $0x4,%edi
  800bf5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bf8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bfb:	fd                   	std    
  800bfc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bfe:	eb 07                	jmp    800c07 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c00:	4f                   	dec    %edi
  800c01:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c04:	fd                   	std    
  800c05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c07:	fc                   	cld    
  800c08:	eb 20                	jmp    800c2a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c10:	75 13                	jne    800c25 <memmove+0x61>
  800c12:	a8 03                	test   $0x3,%al
  800c14:	75 0f                	jne    800c25 <memmove+0x61>
  800c16:	f6 c1 03             	test   $0x3,%cl
  800c19:	75 0a                	jne    800c25 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c1b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c1e:	89 c7                	mov    %eax,%edi
  800c20:	fc                   	cld    
  800c21:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c23:	eb 05                	jmp    800c2a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c25:	89 c7                	mov    %eax,%edi
  800c27:	fc                   	cld    
  800c28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c34:	8b 45 10             	mov    0x10(%ebp),%eax
  800c37:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c42:	8b 45 08             	mov    0x8(%ebp),%eax
  800c45:	89 04 24             	mov    %eax,(%esp)
  800c48:	e8 77 ff ff ff       	call   800bc4 <memmove>
}
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    

00800c4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c58:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c63:	eb 16                	jmp    800c7b <memcmp+0x2c>
		if (*s1 != *s2)
  800c65:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c68:	42                   	inc    %edx
  800c69:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c6d:	38 c8                	cmp    %cl,%al
  800c6f:	74 0a                	je     800c7b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c71:	0f b6 c0             	movzbl %al,%eax
  800c74:	0f b6 c9             	movzbl %cl,%ecx
  800c77:	29 c8                	sub    %ecx,%eax
  800c79:	eb 09                	jmp    800c84 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7b:	39 da                	cmp    %ebx,%edx
  800c7d:	75 e6                	jne    800c65 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c92:	89 c2                	mov    %eax,%edx
  800c94:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c97:	eb 05                	jmp    800c9e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c99:	38 08                	cmp    %cl,(%eax)
  800c9b:	74 05                	je     800ca2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c9d:	40                   	inc    %eax
  800c9e:	39 d0                	cmp    %edx,%eax
  800ca0:	72 f7                	jb     800c99 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb0:	eb 01                	jmp    800cb3 <strtol+0xf>
		s++;
  800cb2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb3:	8a 02                	mov    (%edx),%al
  800cb5:	3c 20                	cmp    $0x20,%al
  800cb7:	74 f9                	je     800cb2 <strtol+0xe>
  800cb9:	3c 09                	cmp    $0x9,%al
  800cbb:	74 f5                	je     800cb2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cbd:	3c 2b                	cmp    $0x2b,%al
  800cbf:	75 08                	jne    800cc9 <strtol+0x25>
		s++;
  800cc1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cc2:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc7:	eb 13                	jmp    800cdc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cc9:	3c 2d                	cmp    $0x2d,%al
  800ccb:	75 0a                	jne    800cd7 <strtol+0x33>
		s++, neg = 1;
  800ccd:	8d 52 01             	lea    0x1(%edx),%edx
  800cd0:	bf 01 00 00 00       	mov    $0x1,%edi
  800cd5:	eb 05                	jmp    800cdc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cd7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cdc:	85 db                	test   %ebx,%ebx
  800cde:	74 05                	je     800ce5 <strtol+0x41>
  800ce0:	83 fb 10             	cmp    $0x10,%ebx
  800ce3:	75 28                	jne    800d0d <strtol+0x69>
  800ce5:	8a 02                	mov    (%edx),%al
  800ce7:	3c 30                	cmp    $0x30,%al
  800ce9:	75 10                	jne    800cfb <strtol+0x57>
  800ceb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cef:	75 0a                	jne    800cfb <strtol+0x57>
		s += 2, base = 16;
  800cf1:	83 c2 02             	add    $0x2,%edx
  800cf4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cf9:	eb 12                	jmp    800d0d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cfb:	85 db                	test   %ebx,%ebx
  800cfd:	75 0e                	jne    800d0d <strtol+0x69>
  800cff:	3c 30                	cmp    $0x30,%al
  800d01:	75 05                	jne    800d08 <strtol+0x64>
		s++, base = 8;
  800d03:	42                   	inc    %edx
  800d04:	b3 08                	mov    $0x8,%bl
  800d06:	eb 05                	jmp    800d0d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d08:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d12:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d14:	8a 0a                	mov    (%edx),%cl
  800d16:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d19:	80 fb 09             	cmp    $0x9,%bl
  800d1c:	77 08                	ja     800d26 <strtol+0x82>
			dig = *s - '0';
  800d1e:	0f be c9             	movsbl %cl,%ecx
  800d21:	83 e9 30             	sub    $0x30,%ecx
  800d24:	eb 1e                	jmp    800d44 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d26:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d29:	80 fb 19             	cmp    $0x19,%bl
  800d2c:	77 08                	ja     800d36 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d2e:	0f be c9             	movsbl %cl,%ecx
  800d31:	83 e9 57             	sub    $0x57,%ecx
  800d34:	eb 0e                	jmp    800d44 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d36:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d39:	80 fb 19             	cmp    $0x19,%bl
  800d3c:	77 12                	ja     800d50 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d3e:	0f be c9             	movsbl %cl,%ecx
  800d41:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d44:	39 f1                	cmp    %esi,%ecx
  800d46:	7d 0c                	jge    800d54 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d48:	42                   	inc    %edx
  800d49:	0f af c6             	imul   %esi,%eax
  800d4c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d4e:	eb c4                	jmp    800d14 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d50:	89 c1                	mov    %eax,%ecx
  800d52:	eb 02                	jmp    800d56 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d54:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d56:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d5a:	74 05                	je     800d61 <strtol+0xbd>
		*endptr = (char *) s;
  800d5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d5f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d61:	85 ff                	test   %edi,%edi
  800d63:	74 04                	je     800d69 <strtol+0xc5>
  800d65:	89 c8                	mov    %ecx,%eax
  800d67:	f7 d8                	neg    %eax
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    
	...

00800d70 <__udivdi3>:
  800d70:	55                   	push   %ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	83 ec 10             	sub    $0x10,%esp
  800d76:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d7a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d7e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d82:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800d86:	89 cd                	mov    %ecx,%ebp
  800d88:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	75 2c                	jne    800dbc <__udivdi3+0x4c>
  800d90:	39 f9                	cmp    %edi,%ecx
  800d92:	77 68                	ja     800dfc <__udivdi3+0x8c>
  800d94:	85 c9                	test   %ecx,%ecx
  800d96:	75 0b                	jne    800da3 <__udivdi3+0x33>
  800d98:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9d:	31 d2                	xor    %edx,%edx
  800d9f:	f7 f1                	div    %ecx
  800da1:	89 c1                	mov    %eax,%ecx
  800da3:	31 d2                	xor    %edx,%edx
  800da5:	89 f8                	mov    %edi,%eax
  800da7:	f7 f1                	div    %ecx
  800da9:	89 c7                	mov    %eax,%edi
  800dab:	89 f0                	mov    %esi,%eax
  800dad:	f7 f1                	div    %ecx
  800daf:	89 c6                	mov    %eax,%esi
  800db1:	89 f0                	mov    %esi,%eax
  800db3:	89 fa                	mov    %edi,%edx
  800db5:	83 c4 10             	add    $0x10,%esp
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    
  800dbc:	39 f8                	cmp    %edi,%eax
  800dbe:	77 2c                	ja     800dec <__udivdi3+0x7c>
  800dc0:	0f bd f0             	bsr    %eax,%esi
  800dc3:	83 f6 1f             	xor    $0x1f,%esi
  800dc6:	75 4c                	jne    800e14 <__udivdi3+0xa4>
  800dc8:	39 f8                	cmp    %edi,%eax
  800dca:	bf 00 00 00 00       	mov    $0x0,%edi
  800dcf:	72 0a                	jb     800ddb <__udivdi3+0x6b>
  800dd1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800dd5:	0f 87 ad 00 00 00    	ja     800e88 <__udivdi3+0x118>
  800ddb:	be 01 00 00 00       	mov    $0x1,%esi
  800de0:	89 f0                	mov    %esi,%eax
  800de2:	89 fa                	mov    %edi,%edx
  800de4:	83 c4 10             	add    $0x10,%esp
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    
  800deb:	90                   	nop
  800dec:	31 ff                	xor    %edi,%edi
  800dee:	31 f6                	xor    %esi,%esi
  800df0:	89 f0                	mov    %esi,%eax
  800df2:	89 fa                	mov    %edi,%edx
  800df4:	83 c4 10             	add    $0x10,%esp
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    
  800dfb:	90                   	nop
  800dfc:	89 fa                	mov    %edi,%edx
  800dfe:	89 f0                	mov    %esi,%eax
  800e00:	f7 f1                	div    %ecx
  800e02:	89 c6                	mov    %eax,%esi
  800e04:	31 ff                	xor    %edi,%edi
  800e06:	89 f0                	mov    %esi,%eax
  800e08:	89 fa                	mov    %edi,%edx
  800e0a:	83 c4 10             	add    $0x10,%esp
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    
  800e11:	8d 76 00             	lea    0x0(%esi),%esi
  800e14:	89 f1                	mov    %esi,%ecx
  800e16:	d3 e0                	shl    %cl,%eax
  800e18:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e1c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e21:	29 f0                	sub    %esi,%eax
  800e23:	89 ea                	mov    %ebp,%edx
  800e25:	88 c1                	mov    %al,%cl
  800e27:	d3 ea                	shr    %cl,%edx
  800e29:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e2d:	09 ca                	or     %ecx,%edx
  800e2f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e33:	89 f1                	mov    %esi,%ecx
  800e35:	d3 e5                	shl    %cl,%ebp
  800e37:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e3b:	89 fd                	mov    %edi,%ebp
  800e3d:	88 c1                	mov    %al,%cl
  800e3f:	d3 ed                	shr    %cl,%ebp
  800e41:	89 fa                	mov    %edi,%edx
  800e43:	89 f1                	mov    %esi,%ecx
  800e45:	d3 e2                	shl    %cl,%edx
  800e47:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e4b:	88 c1                	mov    %al,%cl
  800e4d:	d3 ef                	shr    %cl,%edi
  800e4f:	09 d7                	or     %edx,%edi
  800e51:	89 f8                	mov    %edi,%eax
  800e53:	89 ea                	mov    %ebp,%edx
  800e55:	f7 74 24 08          	divl   0x8(%esp)
  800e59:	89 d1                	mov    %edx,%ecx
  800e5b:	89 c7                	mov    %eax,%edi
  800e5d:	f7 64 24 0c          	mull   0xc(%esp)
  800e61:	39 d1                	cmp    %edx,%ecx
  800e63:	72 17                	jb     800e7c <__udivdi3+0x10c>
  800e65:	74 09                	je     800e70 <__udivdi3+0x100>
  800e67:	89 fe                	mov    %edi,%esi
  800e69:	31 ff                	xor    %edi,%edi
  800e6b:	e9 41 ff ff ff       	jmp    800db1 <__udivdi3+0x41>
  800e70:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e74:	89 f1                	mov    %esi,%ecx
  800e76:	d3 e2                	shl    %cl,%edx
  800e78:	39 c2                	cmp    %eax,%edx
  800e7a:	73 eb                	jae    800e67 <__udivdi3+0xf7>
  800e7c:	8d 77 ff             	lea    -0x1(%edi),%esi
  800e7f:	31 ff                	xor    %edi,%edi
  800e81:	e9 2b ff ff ff       	jmp    800db1 <__udivdi3+0x41>
  800e86:	66 90                	xchg   %ax,%ax
  800e88:	31 f6                	xor    %esi,%esi
  800e8a:	e9 22 ff ff ff       	jmp    800db1 <__udivdi3+0x41>
	...

00800e90 <__umoddi3>:
  800e90:	55                   	push   %ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	83 ec 20             	sub    $0x20,%esp
  800e96:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e9a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800e9e:	89 44 24 14          	mov    %eax,0x14(%esp)
  800ea2:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ea6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800eaa:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800eae:	89 c7                	mov    %eax,%edi
  800eb0:	89 f2                	mov    %esi,%edx
  800eb2:	85 ed                	test   %ebp,%ebp
  800eb4:	75 16                	jne    800ecc <__umoddi3+0x3c>
  800eb6:	39 f1                	cmp    %esi,%ecx
  800eb8:	0f 86 a6 00 00 00    	jbe    800f64 <__umoddi3+0xd4>
  800ebe:	f7 f1                	div    %ecx
  800ec0:	89 d0                	mov    %edx,%eax
  800ec2:	31 d2                	xor    %edx,%edx
  800ec4:	83 c4 20             	add    $0x20,%esp
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    
  800ecb:	90                   	nop
  800ecc:	39 f5                	cmp    %esi,%ebp
  800ece:	0f 87 ac 00 00 00    	ja     800f80 <__umoddi3+0xf0>
  800ed4:	0f bd c5             	bsr    %ebp,%eax
  800ed7:	83 f0 1f             	xor    $0x1f,%eax
  800eda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ede:	0f 84 a8 00 00 00    	je     800f8c <__umoddi3+0xfc>
  800ee4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ee8:	d3 e5                	shl    %cl,%ebp
  800eea:	bf 20 00 00 00       	mov    $0x20,%edi
  800eef:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800ef3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ef7:	89 f9                	mov    %edi,%ecx
  800ef9:	d3 e8                	shr    %cl,%eax
  800efb:	09 e8                	or     %ebp,%eax
  800efd:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f01:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f05:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f09:	d3 e0                	shl    %cl,%eax
  800f0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f0f:	89 f2                	mov    %esi,%edx
  800f11:	d3 e2                	shl    %cl,%edx
  800f13:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f17:	d3 e0                	shl    %cl,%eax
  800f19:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f1d:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f21:	89 f9                	mov    %edi,%ecx
  800f23:	d3 e8                	shr    %cl,%eax
  800f25:	09 d0                	or     %edx,%eax
  800f27:	d3 ee                	shr    %cl,%esi
  800f29:	89 f2                	mov    %esi,%edx
  800f2b:	f7 74 24 18          	divl   0x18(%esp)
  800f2f:	89 d6                	mov    %edx,%esi
  800f31:	f7 64 24 0c          	mull   0xc(%esp)
  800f35:	89 c5                	mov    %eax,%ebp
  800f37:	89 d1                	mov    %edx,%ecx
  800f39:	39 d6                	cmp    %edx,%esi
  800f3b:	72 67                	jb     800fa4 <__umoddi3+0x114>
  800f3d:	74 75                	je     800fb4 <__umoddi3+0x124>
  800f3f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f43:	29 e8                	sub    %ebp,%eax
  800f45:	19 ce                	sbb    %ecx,%esi
  800f47:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f4b:	d3 e8                	shr    %cl,%eax
  800f4d:	89 f2                	mov    %esi,%edx
  800f4f:	89 f9                	mov    %edi,%ecx
  800f51:	d3 e2                	shl    %cl,%edx
  800f53:	09 d0                	or     %edx,%eax
  800f55:	89 f2                	mov    %esi,%edx
  800f57:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f5b:	d3 ea                	shr    %cl,%edx
  800f5d:	83 c4 20             	add    $0x20,%esp
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    
  800f64:	85 c9                	test   %ecx,%ecx
  800f66:	75 0b                	jne    800f73 <__umoddi3+0xe3>
  800f68:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6d:	31 d2                	xor    %edx,%edx
  800f6f:	f7 f1                	div    %ecx
  800f71:	89 c1                	mov    %eax,%ecx
  800f73:	89 f0                	mov    %esi,%eax
  800f75:	31 d2                	xor    %edx,%edx
  800f77:	f7 f1                	div    %ecx
  800f79:	89 f8                	mov    %edi,%eax
  800f7b:	e9 3e ff ff ff       	jmp    800ebe <__umoddi3+0x2e>
  800f80:	89 f2                	mov    %esi,%edx
  800f82:	83 c4 20             	add    $0x20,%esp
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    
  800f89:	8d 76 00             	lea    0x0(%esi),%esi
  800f8c:	39 f5                	cmp    %esi,%ebp
  800f8e:	72 04                	jb     800f94 <__umoddi3+0x104>
  800f90:	39 f9                	cmp    %edi,%ecx
  800f92:	77 06                	ja     800f9a <__umoddi3+0x10a>
  800f94:	89 f2                	mov    %esi,%edx
  800f96:	29 cf                	sub    %ecx,%edi
  800f98:	19 ea                	sbb    %ebp,%edx
  800f9a:	89 f8                	mov    %edi,%eax
  800f9c:	83 c4 20             	add    $0x20,%esp
  800f9f:	5e                   	pop    %esi
  800fa0:	5f                   	pop    %edi
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    
  800fa3:	90                   	nop
  800fa4:	89 d1                	mov    %edx,%ecx
  800fa6:	89 c5                	mov    %eax,%ebp
  800fa8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fac:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fb0:	eb 8d                	jmp    800f3f <__umoddi3+0xaf>
  800fb2:	66 90                	xchg   %ax,%ax
  800fb4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fb8:	72 ea                	jb     800fa4 <__umoddi3+0x114>
  800fba:	89 f1                	mov    %esi,%ecx
  800fbc:	eb 81                	jmp    800f3f <__umoddi3+0xaf>


obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 04 04 80 	movl   $0x800404,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 eb 02 00 00       	call   800339 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	83 ec 10             	sub    $0x10,%esp
  800064:	8b 75 08             	mov    0x8(%ebp),%esi
  800067:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80006a:	e8 ec 00 00 00       	call   80015b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80006f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800074:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007b:	c1 e0 07             	shl    $0x7,%eax
  80007e:	29 d0                	sub    %edx,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 f6                	test   %esi,%esi
  80008c:	7e 07                	jle    800095 <libmain+0x39>
		binaryname = argv[0];
  80008e:	8b 03                	mov    (%ebx),%eax
  800090:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800095:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800099:	89 34 24             	mov    %esi,(%esp)
  80009c:	e8 93 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a1:	e8 0a 00 00 00       	call   8000b0 <exit>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    
  8000ad:	00 00                	add    %al,(%eax)
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000b6:	e8 54 05 00 00       	call   80060f <close_all>
	sys_env_destroy(0);
  8000bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c2:	e8 42 00 00 00       	call   800109 <sys_env_destroy>
}
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    
  8000c9:	00 00                	add    %al,(%eax)
	...

008000cc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000da:	8b 55 08             	mov    0x8(%ebp),%edx
  8000dd:	89 c3                	mov    %eax,%ebx
  8000df:	89 c7                	mov    %eax,%edi
  8000e1:	89 c6                	mov    %eax,%esi
  8000e3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e5:	5b                   	pop    %ebx
  8000e6:	5e                   	pop    %esi
  8000e7:	5f                   	pop    %edi
  8000e8:	5d                   	pop    %ebp
  8000e9:	c3                   	ret    

008000ea <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	57                   	push   %edi
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fa:	89 d1                	mov    %edx,%ecx
  8000fc:	89 d3                	mov    %edx,%ebx
  8000fe:	89 d7                	mov    %edx,%edi
  800100:	89 d6                	mov    %edx,%esi
  800102:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	5f                   	pop    %edi
  800107:	5d                   	pop    %ebp
  800108:	c3                   	ret    

00800109 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800109:	55                   	push   %ebp
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	57                   	push   %edi
  80010d:	56                   	push   %esi
  80010e:	53                   	push   %ebx
  80010f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800112:	b9 00 00 00 00       	mov    $0x0,%ecx
  800117:	b8 03 00 00 00       	mov    $0x3,%eax
  80011c:	8b 55 08             	mov    0x8(%ebp),%edx
  80011f:	89 cb                	mov    %ecx,%ebx
  800121:	89 cf                	mov    %ecx,%edi
  800123:	89 ce                	mov    %ecx,%esi
  800125:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800127:	85 c0                	test   %eax,%eax
  800129:	7e 28                	jle    800153 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80012f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800136:	00 
  800137:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  80013e:	00 
  80013f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800146:	00 
  800147:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  80014e:	e8 4d 10 00 00       	call   8011a0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800153:	83 c4 2c             	add    $0x2c,%esp
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800161:	ba 00 00 00 00       	mov    $0x0,%edx
  800166:	b8 02 00 00 00       	mov    $0x2,%eax
  80016b:	89 d1                	mov    %edx,%ecx
  80016d:	89 d3                	mov    %edx,%ebx
  80016f:	89 d7                	mov    %edx,%edi
  800171:	89 d6                	mov    %edx,%esi
  800173:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5f                   	pop    %edi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <sys_yield>:

void
sys_yield(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	57                   	push   %edi
  80017e:	56                   	push   %esi
  80017f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800180:	ba 00 00 00 00       	mov    $0x0,%edx
  800185:	b8 0b 00 00 00       	mov    $0xb,%eax
  80018a:	89 d1                	mov    %edx,%ecx
  80018c:	89 d3                	mov    %edx,%ebx
  80018e:	89 d7                	mov    %edx,%edi
  800190:	89 d6                	mov    %edx,%esi
  800192:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	be 00 00 00 00       	mov    $0x0,%esi
  8001a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	89 f7                	mov    %esi,%edi
  8001b7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b9:	85 c0                	test   %eax,%eax
  8001bb:	7e 28                	jle    8001e5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001c1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  8001d0:	00 
  8001d1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001d8:	00 
  8001d9:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  8001e0:	e8 bb 0f 00 00       	call   8011a0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001e5:	83 c4 2c             	add    $0x2c,%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001fb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001fe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800201:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800204:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800207:	8b 55 08             	mov    0x8(%ebp),%edx
  80020a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 28                	jle    800238 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	89 44 24 10          	mov    %eax,0x10(%esp)
  800214:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80021b:	00 
  80021c:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  800223:	00 
  800224:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80022b:	00 
  80022c:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  800233:	e8 68 0f 00 00       	call   8011a0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800238:	83 c4 2c             	add    $0x2c,%esp
  80023b:	5b                   	pop    %ebx
  80023c:	5e                   	pop    %esi
  80023d:	5f                   	pop    %edi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024e:	b8 06 00 00 00       	mov    $0x6,%eax
  800253:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	89 df                	mov    %ebx,%edi
  80025b:	89 de                	mov    %ebx,%esi
  80025d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80025f:	85 c0                	test   %eax,%eax
  800261:	7e 28                	jle    80028b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800263:	89 44 24 10          	mov    %eax,0x10(%esp)
  800267:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80026e:	00 
  80026f:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  800276:	00 
  800277:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80027e:	00 
  80027f:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  800286:	e8 15 0f 00 00       	call   8011a0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80028b:	83 c4 2c             	add    $0x2c,%esp
  80028e:	5b                   	pop    %ebx
  80028f:	5e                   	pop    %esi
  800290:	5f                   	pop    %edi
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    

00800293 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	57                   	push   %edi
  800297:	56                   	push   %esi
  800298:	53                   	push   %ebx
  800299:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	b8 08 00 00 00       	mov    $0x8,%eax
  8002a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ac:	89 df                	mov    %ebx,%edi
  8002ae:	89 de                	mov    %ebx,%esi
  8002b0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	7e 28                	jle    8002de <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ba:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  8002c9:	00 
  8002ca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002d1:	00 
  8002d2:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  8002d9:	e8 c2 0e 00 00       	call   8011a0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002de:	83 c4 2c             	add    $0x2c,%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	57                   	push   %edi
  8002ea:	56                   	push   %esi
  8002eb:	53                   	push   %ebx
  8002ec:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ff:	89 df                	mov    %ebx,%edi
  800301:	89 de                	mov    %ebx,%esi
  800303:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800305:	85 c0                	test   %eax,%eax
  800307:	7e 28                	jle    800331 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800309:	89 44 24 10          	mov    %eax,0x10(%esp)
  80030d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800314:	00 
  800315:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  80031c:	00 
  80031d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800324:	00 
  800325:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  80032c:	e8 6f 0e 00 00       	call   8011a0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800331:	83 c4 2c             	add    $0x2c,%esp
  800334:	5b                   	pop    %ebx
  800335:	5e                   	pop    %esi
  800336:	5f                   	pop    %edi
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	57                   	push   %edi
  80033d:	56                   	push   %esi
  80033e:	53                   	push   %ebx
  80033f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800342:	bb 00 00 00 00       	mov    $0x0,%ebx
  800347:	b8 0a 00 00 00       	mov    $0xa,%eax
  80034c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034f:	8b 55 08             	mov    0x8(%ebp),%edx
  800352:	89 df                	mov    %ebx,%edi
  800354:	89 de                	mov    %ebx,%esi
  800356:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800358:	85 c0                	test   %eax,%eax
  80035a:	7e 28                	jle    800384 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800360:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800367:	00 
  800368:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  80036f:	00 
  800370:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800377:	00 
  800378:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  80037f:	e8 1c 0e 00 00       	call   8011a0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800384:	83 c4 2c             	add    $0x2c,%esp
  800387:	5b                   	pop    %ebx
  800388:	5e                   	pop    %esi
  800389:	5f                   	pop    %edi
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	57                   	push   %edi
  800390:	56                   	push   %esi
  800391:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800392:	be 00 00 00 00       	mov    $0x0,%esi
  800397:	b8 0c 00 00 00       	mov    $0xc,%eax
  80039c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80039f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003aa:	5b                   	pop    %ebx
  8003ab:	5e                   	pop    %esi
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	57                   	push   %edi
  8003b3:	56                   	push   %esi
  8003b4:	53                   	push   %ebx
  8003b5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003bd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c5:	89 cb                	mov    %ecx,%ebx
  8003c7:	89 cf                	mov    %ecx,%edi
  8003c9:	89 ce                	mov    %ecx,%esi
  8003cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003cd:	85 c0                	test   %eax,%eax
  8003cf:	7e 28                	jle    8003f9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003d5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003dc:	00 
  8003dd:	c7 44 24 08 ea 1f 80 	movl   $0x801fea,0x8(%esp)
  8003e4:	00 
  8003e5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003ec:	00 
  8003ed:	c7 04 24 07 20 80 00 	movl   $0x802007,(%esp)
  8003f4:	e8 a7 0d 00 00       	call   8011a0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003f9:	83 c4 2c             	add    $0x2c,%esp
  8003fc:	5b                   	pop    %ebx
  8003fd:	5e                   	pop    %esi
  8003fe:	5f                   	pop    %edi
  8003ff:	5d                   	pop    %ebp
  800400:	c3                   	ret    
  800401:	00 00                	add    %al,(%eax)
	...

00800404 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800404:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800405:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80040a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80040c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  80040f:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  800413:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  800415:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  800418:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  800419:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  80041c:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  80041e:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  800421:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  800422:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  800425:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800426:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800427:	c3                   	ret    

00800428 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80042b:	8b 45 08             	mov    0x8(%ebp),%eax
  80042e:	05 00 00 00 30       	add    $0x30000000,%eax
  800433:	c1 e8 0c             	shr    $0xc,%eax
}
  800436:	5d                   	pop    %ebp
  800437:	c3                   	ret    

00800438 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80043e:	8b 45 08             	mov    0x8(%ebp),%eax
  800441:	89 04 24             	mov    %eax,(%esp)
  800444:	e8 df ff ff ff       	call   800428 <fd2num>
  800449:	05 20 00 0d 00       	add    $0xd0020,%eax
  80044e:	c1 e0 0c             	shl    $0xc,%eax
}
  800451:	c9                   	leave  
  800452:	c3                   	ret    

00800453 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800453:	55                   	push   %ebp
  800454:	89 e5                	mov    %esp,%ebp
  800456:	53                   	push   %ebx
  800457:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80045a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80045f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800461:	89 c2                	mov    %eax,%edx
  800463:	c1 ea 16             	shr    $0x16,%edx
  800466:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80046d:	f6 c2 01             	test   $0x1,%dl
  800470:	74 11                	je     800483 <fd_alloc+0x30>
  800472:	89 c2                	mov    %eax,%edx
  800474:	c1 ea 0c             	shr    $0xc,%edx
  800477:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80047e:	f6 c2 01             	test   $0x1,%dl
  800481:	75 09                	jne    80048c <fd_alloc+0x39>
			*fd_store = fd;
  800483:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800485:	b8 00 00 00 00       	mov    $0x0,%eax
  80048a:	eb 17                	jmp    8004a3 <fd_alloc+0x50>
  80048c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800491:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800496:	75 c7                	jne    80045f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800498:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80049e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8004a3:	5b                   	pop    %ebx
  8004a4:	5d                   	pop    %ebp
  8004a5:	c3                   	ret    

008004a6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
  8004a9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004ac:	83 f8 1f             	cmp    $0x1f,%eax
  8004af:	77 36                	ja     8004e7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004b1:	05 00 00 0d 00       	add    $0xd0000,%eax
  8004b6:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004b9:	89 c2                	mov    %eax,%edx
  8004bb:	c1 ea 16             	shr    $0x16,%edx
  8004be:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004c5:	f6 c2 01             	test   $0x1,%dl
  8004c8:	74 24                	je     8004ee <fd_lookup+0x48>
  8004ca:	89 c2                	mov    %eax,%edx
  8004cc:	c1 ea 0c             	shr    $0xc,%edx
  8004cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004d6:	f6 c2 01             	test   $0x1,%dl
  8004d9:	74 1a                	je     8004f5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004de:	89 02                	mov    %eax,(%edx)
	return 0;
  8004e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e5:	eb 13                	jmp    8004fa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004ec:	eb 0c                	jmp    8004fa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004f3:	eb 05                	jmp    8004fa <fd_lookup+0x54>
  8004f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004fa:	5d                   	pop    %ebp
  8004fb:	c3                   	ret    

008004fc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004fc:	55                   	push   %ebp
  8004fd:	89 e5                	mov    %esp,%ebp
  8004ff:	53                   	push   %ebx
  800500:	83 ec 14             	sub    $0x14,%esp
  800503:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800506:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800509:	ba 00 00 00 00       	mov    $0x0,%edx
  80050e:	eb 0e                	jmp    80051e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800510:	39 08                	cmp    %ecx,(%eax)
  800512:	75 09                	jne    80051d <dev_lookup+0x21>
			*dev = devtab[i];
  800514:	89 03                	mov    %eax,(%ebx)
			return 0;
  800516:	b8 00 00 00 00       	mov    $0x0,%eax
  80051b:	eb 33                	jmp    800550 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80051d:	42                   	inc    %edx
  80051e:	8b 04 95 94 20 80 00 	mov    0x802094(,%edx,4),%eax
  800525:	85 c0                	test   %eax,%eax
  800527:	75 e7                	jne    800510 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800529:	a1 04 40 80 00       	mov    0x804004,%eax
  80052e:	8b 40 48             	mov    0x48(%eax),%eax
  800531:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800535:	89 44 24 04          	mov    %eax,0x4(%esp)
  800539:	c7 04 24 18 20 80 00 	movl   $0x802018,(%esp)
  800540:	e8 53 0d 00 00       	call   801298 <cprintf>
	*dev = 0;
  800545:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80054b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800550:	83 c4 14             	add    $0x14,%esp
  800553:	5b                   	pop    %ebx
  800554:	5d                   	pop    %ebp
  800555:	c3                   	ret    

00800556 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	56                   	push   %esi
  80055a:	53                   	push   %ebx
  80055b:	83 ec 30             	sub    $0x30,%esp
  80055e:	8b 75 08             	mov    0x8(%ebp),%esi
  800561:	8a 45 0c             	mov    0xc(%ebp),%al
  800564:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800567:	89 34 24             	mov    %esi,(%esp)
  80056a:	e8 b9 fe ff ff       	call   800428 <fd2num>
  80056f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800572:	89 54 24 04          	mov    %edx,0x4(%esp)
  800576:	89 04 24             	mov    %eax,(%esp)
  800579:	e8 28 ff ff ff       	call   8004a6 <fd_lookup>
  80057e:	89 c3                	mov    %eax,%ebx
  800580:	85 c0                	test   %eax,%eax
  800582:	78 05                	js     800589 <fd_close+0x33>
	    || fd != fd2)
  800584:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800587:	74 0d                	je     800596 <fd_close+0x40>
		return (must_exist ? r : 0);
  800589:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80058d:	75 46                	jne    8005d5 <fd_close+0x7f>
  80058f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800594:	eb 3f                	jmp    8005d5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800596:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800599:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059d:	8b 06                	mov    (%esi),%eax
  80059f:	89 04 24             	mov    %eax,(%esp)
  8005a2:	e8 55 ff ff ff       	call   8004fc <dev_lookup>
  8005a7:	89 c3                	mov    %eax,%ebx
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	78 18                	js     8005c5 <fd_close+0x6f>
		if (dev->dev_close)
  8005ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005b0:	8b 40 10             	mov    0x10(%eax),%eax
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	74 09                	je     8005c0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005b7:	89 34 24             	mov    %esi,(%esp)
  8005ba:	ff d0                	call   *%eax
  8005bc:	89 c3                	mov    %eax,%ebx
  8005be:	eb 05                	jmp    8005c5 <fd_close+0x6f>
		else
			r = 0;
  8005c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005d0:	e8 6b fc ff ff       	call   800240 <sys_page_unmap>
	return r;
}
  8005d5:	89 d8                	mov    %ebx,%eax
  8005d7:	83 c4 30             	add    $0x30,%esp
  8005da:	5b                   	pop    %ebx
  8005db:	5e                   	pop    %esi
  8005dc:	5d                   	pop    %ebp
  8005dd:	c3                   	ret    

008005de <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005de:	55                   	push   %ebp
  8005df:	89 e5                	mov    %esp,%ebp
  8005e1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	89 04 24             	mov    %eax,(%esp)
  8005f1:	e8 b0 fe ff ff       	call   8004a6 <fd_lookup>
  8005f6:	85 c0                	test   %eax,%eax
  8005f8:	78 13                	js     80060d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8005fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800601:	00 
  800602:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800605:	89 04 24             	mov    %eax,(%esp)
  800608:	e8 49 ff ff ff       	call   800556 <fd_close>
}
  80060d:	c9                   	leave  
  80060e:	c3                   	ret    

0080060f <close_all>:

void
close_all(void)
{
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	53                   	push   %ebx
  800613:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800616:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80061b:	89 1c 24             	mov    %ebx,(%esp)
  80061e:	e8 bb ff ff ff       	call   8005de <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800623:	43                   	inc    %ebx
  800624:	83 fb 20             	cmp    $0x20,%ebx
  800627:	75 f2                	jne    80061b <close_all+0xc>
		close(i);
}
  800629:	83 c4 14             	add    $0x14,%esp
  80062c:	5b                   	pop    %ebx
  80062d:	5d                   	pop    %ebp
  80062e:	c3                   	ret    

0080062f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	57                   	push   %edi
  800633:	56                   	push   %esi
  800634:	53                   	push   %ebx
  800635:	83 ec 4c             	sub    $0x4c,%esp
  800638:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80063b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80063e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800642:	8b 45 08             	mov    0x8(%ebp),%eax
  800645:	89 04 24             	mov    %eax,(%esp)
  800648:	e8 59 fe ff ff       	call   8004a6 <fd_lookup>
  80064d:	89 c3                	mov    %eax,%ebx
  80064f:	85 c0                	test   %eax,%eax
  800651:	0f 88 e1 00 00 00    	js     800738 <dup+0x109>
		return r;
	close(newfdnum);
  800657:	89 3c 24             	mov    %edi,(%esp)
  80065a:	e8 7f ff ff ff       	call   8005de <close>

	newfd = INDEX2FD(newfdnum);
  80065f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800665:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800668:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80066b:	89 04 24             	mov    %eax,(%esp)
  80066e:	e8 c5 fd ff ff       	call   800438 <fd2data>
  800673:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800675:	89 34 24             	mov    %esi,(%esp)
  800678:	e8 bb fd ff ff       	call   800438 <fd2data>
  80067d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800680:	89 d8                	mov    %ebx,%eax
  800682:	c1 e8 16             	shr    $0x16,%eax
  800685:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80068c:	a8 01                	test   $0x1,%al
  80068e:	74 46                	je     8006d6 <dup+0xa7>
  800690:	89 d8                	mov    %ebx,%eax
  800692:	c1 e8 0c             	shr    $0xc,%eax
  800695:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80069c:	f6 c2 01             	test   $0x1,%dl
  80069f:	74 35                	je     8006d6 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8006a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006a8:	25 07 0e 00 00       	and    $0xe07,%eax
  8006ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006bf:	00 
  8006c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006cb:	e8 1d fb ff ff       	call   8001ed <sys_page_map>
  8006d0:	89 c3                	mov    %eax,%ebx
  8006d2:	85 c0                	test   %eax,%eax
  8006d4:	78 3b                	js     800711 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006d9:	89 c2                	mov    %eax,%edx
  8006db:	c1 ea 0c             	shr    $0xc,%edx
  8006de:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006e5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006eb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006ef:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006fa:	00 
  8006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800706:	e8 e2 fa ff ff       	call   8001ed <sys_page_map>
  80070b:	89 c3                	mov    %eax,%ebx
  80070d:	85 c0                	test   %eax,%eax
  80070f:	79 25                	jns    800736 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800711:	89 74 24 04          	mov    %esi,0x4(%esp)
  800715:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80071c:	e8 1f fb ff ff       	call   800240 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800721:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800724:	89 44 24 04          	mov    %eax,0x4(%esp)
  800728:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80072f:	e8 0c fb ff ff       	call   800240 <sys_page_unmap>
	return r;
  800734:	eb 02                	jmp    800738 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800736:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800738:	89 d8                	mov    %ebx,%eax
  80073a:	83 c4 4c             	add    $0x4c,%esp
  80073d:	5b                   	pop    %ebx
  80073e:	5e                   	pop    %esi
  80073f:	5f                   	pop    %edi
  800740:	5d                   	pop    %ebp
  800741:	c3                   	ret    

00800742 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800742:	55                   	push   %ebp
  800743:	89 e5                	mov    %esp,%ebp
  800745:	53                   	push   %ebx
  800746:	83 ec 24             	sub    $0x24,%esp
  800749:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80074c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80074f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800753:	89 1c 24             	mov    %ebx,(%esp)
  800756:	e8 4b fd ff ff       	call   8004a6 <fd_lookup>
  80075b:	85 c0                	test   %eax,%eax
  80075d:	78 6d                	js     8007cc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80075f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800762:	89 44 24 04          	mov    %eax,0x4(%esp)
  800766:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800769:	8b 00                	mov    (%eax),%eax
  80076b:	89 04 24             	mov    %eax,(%esp)
  80076e:	e8 89 fd ff ff       	call   8004fc <dev_lookup>
  800773:	85 c0                	test   %eax,%eax
  800775:	78 55                	js     8007cc <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800777:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077a:	8b 50 08             	mov    0x8(%eax),%edx
  80077d:	83 e2 03             	and    $0x3,%edx
  800780:	83 fa 01             	cmp    $0x1,%edx
  800783:	75 23                	jne    8007a8 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800785:	a1 04 40 80 00       	mov    0x804004,%eax
  80078a:	8b 40 48             	mov    0x48(%eax),%eax
  80078d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800791:	89 44 24 04          	mov    %eax,0x4(%esp)
  800795:	c7 04 24 59 20 80 00 	movl   $0x802059,(%esp)
  80079c:	e8 f7 0a 00 00       	call   801298 <cprintf>
		return -E_INVAL;
  8007a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a6:	eb 24                	jmp    8007cc <read+0x8a>
	}
	if (!dev->dev_read)
  8007a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ab:	8b 52 08             	mov    0x8(%edx),%edx
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	74 15                	je     8007c7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8007b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007b5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007c0:	89 04 24             	mov    %eax,(%esp)
  8007c3:	ff d2                	call   *%edx
  8007c5:	eb 05                	jmp    8007cc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8007c7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8007cc:	83 c4 24             	add    $0x24,%esp
  8007cf:	5b                   	pop    %ebx
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	57                   	push   %edi
  8007d6:	56                   	push   %esi
  8007d7:	53                   	push   %ebx
  8007d8:	83 ec 1c             	sub    $0x1c,%esp
  8007db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007de:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007e6:	eb 23                	jmp    80080b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007e8:	89 f0                	mov    %esi,%eax
  8007ea:	29 d8                	sub    %ebx,%eax
  8007ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f3:	01 d8                	add    %ebx,%eax
  8007f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f9:	89 3c 24             	mov    %edi,(%esp)
  8007fc:	e8 41 ff ff ff       	call   800742 <read>
		if (m < 0)
  800801:	85 c0                	test   %eax,%eax
  800803:	78 10                	js     800815 <readn+0x43>
			return m;
		if (m == 0)
  800805:	85 c0                	test   %eax,%eax
  800807:	74 0a                	je     800813 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800809:	01 c3                	add    %eax,%ebx
  80080b:	39 f3                	cmp    %esi,%ebx
  80080d:	72 d9                	jb     8007e8 <readn+0x16>
  80080f:	89 d8                	mov    %ebx,%eax
  800811:	eb 02                	jmp    800815 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800813:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800815:	83 c4 1c             	add    $0x1c,%esp
  800818:	5b                   	pop    %ebx
  800819:	5e                   	pop    %esi
  80081a:	5f                   	pop    %edi
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	53                   	push   %ebx
  800821:	83 ec 24             	sub    $0x24,%esp
  800824:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800827:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80082a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082e:	89 1c 24             	mov    %ebx,(%esp)
  800831:	e8 70 fc ff ff       	call   8004a6 <fd_lookup>
  800836:	85 c0                	test   %eax,%eax
  800838:	78 68                	js     8008a2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800841:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800844:	8b 00                	mov    (%eax),%eax
  800846:	89 04 24             	mov    %eax,(%esp)
  800849:	e8 ae fc ff ff       	call   8004fc <dev_lookup>
  80084e:	85 c0                	test   %eax,%eax
  800850:	78 50                	js     8008a2 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800852:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800855:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800859:	75 23                	jne    80087e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80085b:	a1 04 40 80 00       	mov    0x804004,%eax
  800860:	8b 40 48             	mov    0x48(%eax),%eax
  800863:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800867:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086b:	c7 04 24 75 20 80 00 	movl   $0x802075,(%esp)
  800872:	e8 21 0a 00 00       	call   801298 <cprintf>
		return -E_INVAL;
  800877:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80087c:	eb 24                	jmp    8008a2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80087e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800881:	8b 52 0c             	mov    0xc(%edx),%edx
  800884:	85 d2                	test   %edx,%edx
  800886:	74 15                	je     80089d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800888:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80088b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80088f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800892:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800896:	89 04 24             	mov    %eax,(%esp)
  800899:	ff d2                	call   *%edx
  80089b:	eb 05                	jmp    8008a2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80089d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8008a2:	83 c4 24             	add    $0x24,%esp
  8008a5:	5b                   	pop    %ebx
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008ae:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8008b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	89 04 24             	mov    %eax,(%esp)
  8008bb:	e8 e6 fb ff ff       	call   8004a6 <fd_lookup>
  8008c0:	85 c0                	test   %eax,%eax
  8008c2:	78 0e                	js     8008d2 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ca:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    

008008d4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	53                   	push   %ebx
  8008d8:	83 ec 24             	sub    $0x24,%esp
  8008db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e5:	89 1c 24             	mov    %ebx,(%esp)
  8008e8:	e8 b9 fb ff ff       	call   8004a6 <fd_lookup>
  8008ed:	85 c0                	test   %eax,%eax
  8008ef:	78 61                	js     800952 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008fb:	8b 00                	mov    (%eax),%eax
  8008fd:	89 04 24             	mov    %eax,(%esp)
  800900:	e8 f7 fb ff ff       	call   8004fc <dev_lookup>
  800905:	85 c0                	test   %eax,%eax
  800907:	78 49                	js     800952 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800909:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80090c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800910:	75 23                	jne    800935 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800912:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800917:	8b 40 48             	mov    0x48(%eax),%eax
  80091a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80091e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800922:	c7 04 24 38 20 80 00 	movl   $0x802038,(%esp)
  800929:	e8 6a 09 00 00       	call   801298 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80092e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800933:	eb 1d                	jmp    800952 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800935:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800938:	8b 52 18             	mov    0x18(%edx),%edx
  80093b:	85 d2                	test   %edx,%edx
  80093d:	74 0e                	je     80094d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80093f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800942:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800946:	89 04 24             	mov    %eax,(%esp)
  800949:	ff d2                	call   *%edx
  80094b:	eb 05                	jmp    800952 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80094d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800952:	83 c4 24             	add    $0x24,%esp
  800955:	5b                   	pop    %ebx
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	53                   	push   %ebx
  80095c:	83 ec 24             	sub    $0x24,%esp
  80095f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800962:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800965:	89 44 24 04          	mov    %eax,0x4(%esp)
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	89 04 24             	mov    %eax,(%esp)
  80096f:	e8 32 fb ff ff       	call   8004a6 <fd_lookup>
  800974:	85 c0                	test   %eax,%eax
  800976:	78 52                	js     8009ca <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800978:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80097b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800982:	8b 00                	mov    (%eax),%eax
  800984:	89 04 24             	mov    %eax,(%esp)
  800987:	e8 70 fb ff ff       	call   8004fc <dev_lookup>
  80098c:	85 c0                	test   %eax,%eax
  80098e:	78 3a                	js     8009ca <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800990:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800993:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800997:	74 2c                	je     8009c5 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800999:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80099c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8009a3:	00 00 00 
	stat->st_isdir = 0;
  8009a6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8009ad:	00 00 00 
	stat->st_dev = dev;
  8009b0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009bd:	89 14 24             	mov    %edx,(%esp)
  8009c0:	ff 50 14             	call   *0x14(%eax)
  8009c3:	eb 05                	jmp    8009ca <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8009c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8009ca:	83 c4 24             	add    $0x24,%esp
  8009cd:	5b                   	pop    %ebx
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009df:	00 
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	89 04 24             	mov    %eax,(%esp)
  8009e6:	e8 fe 01 00 00       	call   800be9 <open>
  8009eb:	89 c3                	mov    %eax,%ebx
  8009ed:	85 c0                	test   %eax,%eax
  8009ef:	78 1b                	js     800a0c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f8:	89 1c 24             	mov    %ebx,(%esp)
  8009fb:	e8 58 ff ff ff       	call   800958 <fstat>
  800a00:	89 c6                	mov    %eax,%esi
	close(fd);
  800a02:	89 1c 24             	mov    %ebx,(%esp)
  800a05:	e8 d4 fb ff ff       	call   8005de <close>
	return r;
  800a0a:	89 f3                	mov    %esi,%ebx
}
  800a0c:	89 d8                	mov    %ebx,%eax
  800a0e:	83 c4 10             	add    $0x10,%esp
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    
  800a15:	00 00                	add    %al,(%eax)
	...

00800a18 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	83 ec 10             	sub    $0x10,%esp
  800a20:	89 c3                	mov    %eax,%ebx
  800a22:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a24:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a2b:	75 11                	jne    800a3e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a34:	e8 c0 12 00 00       	call   801cf9 <ipc_find_env>
  800a39:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a3e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a45:	00 
  800a46:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a4d:	00 
  800a4e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a52:	a1 00 40 80 00       	mov    0x804000,%eax
  800a57:	89 04 24             	mov    %eax,(%esp)
  800a5a:	e8 30 12 00 00       	call   801c8f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a5f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a66:	00 
  800a67:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a72:	e8 b1 11 00 00       	call   801c28 <ipc_recv>
}
  800a77:	83 c4 10             	add    $0x10,%esp
  800a7a:	5b                   	pop    %ebx
  800a7b:	5e                   	pop    %esi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a92:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a97:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9c:	b8 02 00 00 00       	mov    $0x2,%eax
  800aa1:	e8 72 ff ff ff       	call   800a18 <fsipc>
}
  800aa6:	c9                   	leave  
  800aa7:	c3                   	ret    

00800aa8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ab9:	ba 00 00 00 00       	mov    $0x0,%edx
  800abe:	b8 06 00 00 00       	mov    $0x6,%eax
  800ac3:	e8 50 ff ff ff       	call   800a18 <fsipc>
}
  800ac8:	c9                   	leave  
  800ac9:	c3                   	ret    

00800aca <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	53                   	push   %ebx
  800ace:	83 ec 14             	sub    $0x14,%esp
  800ad1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	8b 40 0c             	mov    0xc(%eax),%eax
  800ada:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800adf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae4:	b8 05 00 00 00       	mov    $0x5,%eax
  800ae9:	e8 2a ff ff ff       	call   800a18 <fsipc>
  800aee:	85 c0                	test   %eax,%eax
  800af0:	78 2b                	js     800b1d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800af2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800af9:	00 
  800afa:	89 1c 24             	mov    %ebx,(%esp)
  800afd:	e8 61 0d 00 00       	call   801863 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b02:	a1 80 50 80 00       	mov    0x805080,%eax
  800b07:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b0d:	a1 84 50 80 00       	mov    0x805084,%eax
  800b12:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800b18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1d:	83 c4 14             	add    $0x14,%esp
  800b20:	5b                   	pop    %ebx
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800b29:	c7 44 24 08 a4 20 80 	movl   $0x8020a4,0x8(%esp)
  800b30:	00 
  800b31:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800b38:	00 
  800b39:	c7 04 24 c2 20 80 00 	movl   $0x8020c2,(%esp)
  800b40:	e8 5b 06 00 00       	call   8011a0 <_panic>

00800b45 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	83 ec 10             	sub    $0x10,%esp
  800b4d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	8b 40 0c             	mov    0xc(%eax),%eax
  800b56:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b5b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b61:	ba 00 00 00 00       	mov    $0x0,%edx
  800b66:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6b:	e8 a8 fe ff ff       	call   800a18 <fsipc>
  800b70:	89 c3                	mov    %eax,%ebx
  800b72:	85 c0                	test   %eax,%eax
  800b74:	78 6a                	js     800be0 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800b76:	39 c6                	cmp    %eax,%esi
  800b78:	73 24                	jae    800b9e <devfile_read+0x59>
  800b7a:	c7 44 24 0c cd 20 80 	movl   $0x8020cd,0xc(%esp)
  800b81:	00 
  800b82:	c7 44 24 08 d4 20 80 	movl   $0x8020d4,0x8(%esp)
  800b89:	00 
  800b8a:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800b91:	00 
  800b92:	c7 04 24 c2 20 80 00 	movl   $0x8020c2,(%esp)
  800b99:	e8 02 06 00 00       	call   8011a0 <_panic>
	assert(r <= PGSIZE);
  800b9e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ba3:	7e 24                	jle    800bc9 <devfile_read+0x84>
  800ba5:	c7 44 24 0c e9 20 80 	movl   $0x8020e9,0xc(%esp)
  800bac:	00 
  800bad:	c7 44 24 08 d4 20 80 	movl   $0x8020d4,0x8(%esp)
  800bb4:	00 
  800bb5:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800bbc:	00 
  800bbd:	c7 04 24 c2 20 80 00 	movl   $0x8020c2,(%esp)
  800bc4:	e8 d7 05 00 00       	call   8011a0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800bc9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bcd:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800bd4:	00 
  800bd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd8:	89 04 24             	mov    %eax,(%esp)
  800bdb:	e8 fc 0d 00 00       	call   8019dc <memmove>
	return r;
}
  800be0:	89 d8                	mov    %ebx,%eax
  800be2:	83 c4 10             	add    $0x10,%esp
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 20             	sub    $0x20,%esp
  800bf1:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800bf4:	89 34 24             	mov    %esi,(%esp)
  800bf7:	e8 34 0c 00 00       	call   801830 <strlen>
  800bfc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c01:	7f 60                	jg     800c63 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c06:	89 04 24             	mov    %eax,(%esp)
  800c09:	e8 45 f8 ff ff       	call   800453 <fd_alloc>
  800c0e:	89 c3                	mov    %eax,%ebx
  800c10:	85 c0                	test   %eax,%eax
  800c12:	78 54                	js     800c68 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800c14:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c18:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c1f:	e8 3f 0c 00 00       	call   801863 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c27:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c34:	e8 df fd ff ff       	call   800a18 <fsipc>
  800c39:	89 c3                	mov    %eax,%ebx
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	79 15                	jns    800c54 <open+0x6b>
		fd_close(fd, 0);
  800c3f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c46:	00 
  800c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c4a:	89 04 24             	mov    %eax,(%esp)
  800c4d:	e8 04 f9 ff ff       	call   800556 <fd_close>
		return r;
  800c52:	eb 14                	jmp    800c68 <open+0x7f>
	}

	return fd2num(fd);
  800c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c57:	89 04 24             	mov    %eax,(%esp)
  800c5a:	e8 c9 f7 ff ff       	call   800428 <fd2num>
  800c5f:	89 c3                	mov    %eax,%ebx
  800c61:	eb 05                	jmp    800c68 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c63:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c68:	89 d8                	mov    %ebx,%eax
  800c6a:	83 c4 20             	add    $0x20,%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c77:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c81:	e8 92 fd ff ff       	call   800a18 <fsipc>
}
  800c86:	c9                   	leave  
  800c87:	c3                   	ret    

00800c88 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 10             	sub    $0x10,%esp
  800c90:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c93:	8b 45 08             	mov    0x8(%ebp),%eax
  800c96:	89 04 24             	mov    %eax,(%esp)
  800c99:	e8 9a f7 ff ff       	call   800438 <fd2data>
  800c9e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800ca0:	c7 44 24 04 f5 20 80 	movl   $0x8020f5,0x4(%esp)
  800ca7:	00 
  800ca8:	89 34 24             	mov    %esi,(%esp)
  800cab:	e8 b3 0b 00 00       	call   801863 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800cb0:	8b 43 04             	mov    0x4(%ebx),%eax
  800cb3:	2b 03                	sub    (%ebx),%eax
  800cb5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800cbb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800cc2:	00 00 00 
	stat->st_dev = &devpipe;
  800cc5:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800ccc:	30 80 00 
	return 0;
}
  800ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd4:	83 c4 10             	add    $0x10,%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 14             	sub    $0x14,%esp
  800ce2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ce5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ce9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cf0:	e8 4b f5 ff ff       	call   800240 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800cf5:	89 1c 24             	mov    %ebx,(%esp)
  800cf8:	e8 3b f7 ff ff       	call   800438 <fd2data>
  800cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d08:	e8 33 f5 ff ff       	call   800240 <sys_page_unmap>
}
  800d0d:	83 c4 14             	add    $0x14,%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 2c             	sub    $0x2c,%esp
  800d1c:	89 c7                	mov    %eax,%edi
  800d1e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800d21:	a1 04 40 80 00       	mov    0x804004,%eax
  800d26:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800d29:	89 3c 24             	mov    %edi,(%esp)
  800d2c:	e8 0f 10 00 00       	call   801d40 <pageref>
  800d31:	89 c6                	mov    %eax,%esi
  800d33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d36:	89 04 24             	mov    %eax,(%esp)
  800d39:	e8 02 10 00 00       	call   801d40 <pageref>
  800d3e:	39 c6                	cmp    %eax,%esi
  800d40:	0f 94 c0             	sete   %al
  800d43:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800d46:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800d4c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800d4f:	39 cb                	cmp    %ecx,%ebx
  800d51:	75 08                	jne    800d5b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800d53:	83 c4 2c             	add    $0x2c,%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800d5b:	83 f8 01             	cmp    $0x1,%eax
  800d5e:	75 c1                	jne    800d21 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800d60:	8b 42 58             	mov    0x58(%edx),%eax
  800d63:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800d6a:	00 
  800d6b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d73:	c7 04 24 fc 20 80 00 	movl   $0x8020fc,(%esp)
  800d7a:	e8 19 05 00 00       	call   801298 <cprintf>
  800d7f:	eb a0                	jmp    800d21 <_pipeisclosed+0xe>

00800d81 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	83 ec 1c             	sub    $0x1c,%esp
  800d8a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800d8d:	89 34 24             	mov    %esi,(%esp)
  800d90:	e8 a3 f6 ff ff       	call   800438 <fd2data>
  800d95:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d97:	bf 00 00 00 00       	mov    $0x0,%edi
  800d9c:	eb 3c                	jmp    800dda <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800d9e:	89 da                	mov    %ebx,%edx
  800da0:	89 f0                	mov    %esi,%eax
  800da2:	e8 6c ff ff ff       	call   800d13 <_pipeisclosed>
  800da7:	85 c0                	test   %eax,%eax
  800da9:	75 38                	jne    800de3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800dab:	e8 ca f3 ff ff       	call   80017a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800db0:	8b 43 04             	mov    0x4(%ebx),%eax
  800db3:	8b 13                	mov    (%ebx),%edx
  800db5:	83 c2 20             	add    $0x20,%edx
  800db8:	39 d0                	cmp    %edx,%eax
  800dba:	73 e2                	jae    800d9e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800dbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dbf:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800dc2:	89 c2                	mov    %eax,%edx
  800dc4:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800dca:	79 05                	jns    800dd1 <devpipe_write+0x50>
  800dcc:	4a                   	dec    %edx
  800dcd:	83 ca e0             	or     $0xffffffe0,%edx
  800dd0:	42                   	inc    %edx
  800dd1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800dd5:	40                   	inc    %eax
  800dd6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800dd9:	47                   	inc    %edi
  800dda:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ddd:	75 d1                	jne    800db0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ddf:	89 f8                	mov    %edi,%eax
  800de1:	eb 05                	jmp    800de8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800de3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800de8:	83 c4 1c             	add    $0x1c,%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
  800df6:	83 ec 1c             	sub    $0x1c,%esp
  800df9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800dfc:	89 3c 24             	mov    %edi,(%esp)
  800dff:	e8 34 f6 ff ff       	call   800438 <fd2data>
  800e04:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e06:	be 00 00 00 00       	mov    $0x0,%esi
  800e0b:	eb 3a                	jmp    800e47 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800e0d:	85 f6                	test   %esi,%esi
  800e0f:	74 04                	je     800e15 <devpipe_read+0x25>
				return i;
  800e11:	89 f0                	mov    %esi,%eax
  800e13:	eb 40                	jmp    800e55 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800e15:	89 da                	mov    %ebx,%edx
  800e17:	89 f8                	mov    %edi,%eax
  800e19:	e8 f5 fe ff ff       	call   800d13 <_pipeisclosed>
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	75 2e                	jne    800e50 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800e22:	e8 53 f3 ff ff       	call   80017a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800e27:	8b 03                	mov    (%ebx),%eax
  800e29:	3b 43 04             	cmp    0x4(%ebx),%eax
  800e2c:	74 df                	je     800e0d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800e2e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800e33:	79 05                	jns    800e3a <devpipe_read+0x4a>
  800e35:	48                   	dec    %eax
  800e36:	83 c8 e0             	or     $0xffffffe0,%eax
  800e39:	40                   	inc    %eax
  800e3a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800e3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e41:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800e44:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e46:	46                   	inc    %esi
  800e47:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e4a:	75 db                	jne    800e27 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800e4c:	89 f0                	mov    %esi,%eax
  800e4e:	eb 05                	jmp    800e55 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e50:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800e55:	83 c4 1c             	add    $0x1c,%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	83 ec 3c             	sub    $0x3c,%esp
  800e66:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800e69:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e6c:	89 04 24             	mov    %eax,(%esp)
  800e6f:	e8 df f5 ff ff       	call   800453 <fd_alloc>
  800e74:	89 c3                	mov    %eax,%ebx
  800e76:	85 c0                	test   %eax,%eax
  800e78:	0f 88 45 01 00 00    	js     800fc3 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e7e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e85:	00 
  800e86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e89:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e94:	e8 00 f3 ff ff       	call   800199 <sys_page_alloc>
  800e99:	89 c3                	mov    %eax,%ebx
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	0f 88 20 01 00 00    	js     800fc3 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800ea3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ea6:	89 04 24             	mov    %eax,(%esp)
  800ea9:	e8 a5 f5 ff ff       	call   800453 <fd_alloc>
  800eae:	89 c3                	mov    %eax,%ebx
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	0f 88 f8 00 00 00    	js     800fb0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800eb8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ebf:	00 
  800ec0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ec3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ec7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ece:	e8 c6 f2 ff ff       	call   800199 <sys_page_alloc>
  800ed3:	89 c3                	mov    %eax,%ebx
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	0f 88 d3 00 00 00    	js     800fb0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800edd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ee0:	89 04 24             	mov    %eax,(%esp)
  800ee3:	e8 50 f5 ff ff       	call   800438 <fd2data>
  800ee8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800eea:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ef1:	00 
  800ef2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ef6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800efd:	e8 97 f2 ff ff       	call   800199 <sys_page_alloc>
  800f02:	89 c3                	mov    %eax,%ebx
  800f04:	85 c0                	test   %eax,%eax
  800f06:	0f 88 91 00 00 00    	js     800f9d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f0f:	89 04 24             	mov    %eax,(%esp)
  800f12:	e8 21 f5 ff ff       	call   800438 <fd2data>
  800f17:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800f1e:	00 
  800f1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f23:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f2a:	00 
  800f2b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f36:	e8 b2 f2 ff ff       	call   8001ed <sys_page_map>
  800f3b:	89 c3                	mov    %eax,%ebx
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	78 4c                	js     800f8d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800f41:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f4a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800f4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f4f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800f56:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f5f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800f61:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f64:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800f6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f6e:	89 04 24             	mov    %eax,(%esp)
  800f71:	e8 b2 f4 ff ff       	call   800428 <fd2num>
  800f76:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800f78:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f7b:	89 04 24             	mov    %eax,(%esp)
  800f7e:	e8 a5 f4 ff ff       	call   800428 <fd2num>
  800f83:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800f86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8b:	eb 36                	jmp    800fc3 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  800f8d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f98:	e8 a3 f2 ff ff       	call   800240 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  800f9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fa0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fab:	e8 90 f2 ff ff       	call   800240 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  800fb0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fbe:	e8 7d f2 ff ff       	call   800240 <sys_page_unmap>
    err:
	return r;
}
  800fc3:	89 d8                	mov    %ebx,%eax
  800fc5:	83 c4 3c             	add    $0x3c,%esp
  800fc8:	5b                   	pop    %ebx
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    

00800fcd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fda:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdd:	89 04 24             	mov    %eax,(%esp)
  800fe0:	e8 c1 f4 ff ff       	call   8004a6 <fd_lookup>
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	78 15                	js     800ffe <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fec:	89 04 24             	mov    %eax,(%esp)
  800fef:	e8 44 f4 ff ff       	call   800438 <fd2data>
	return _pipeisclosed(fd, p);
  800ff4:	89 c2                	mov    %eax,%edx
  800ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff9:	e8 15 fd ff ff       	call   800d13 <_pipeisclosed>
}
  800ffe:	c9                   	leave  
  800fff:	c3                   	ret    

00801000 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801003:	b8 00 00 00 00       	mov    $0x0,%eax
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    

0080100a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801010:	c7 44 24 04 14 21 80 	movl   $0x802114,0x4(%esp)
  801017:	00 
  801018:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101b:	89 04 24             	mov    %eax,(%esp)
  80101e:	e8 40 08 00 00       	call   801863 <strcpy>
	return 0;
}
  801023:	b8 00 00 00 00       	mov    $0x0,%eax
  801028:	c9                   	leave  
  801029:	c3                   	ret    

0080102a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	57                   	push   %edi
  80102e:	56                   	push   %esi
  80102f:	53                   	push   %ebx
  801030:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801036:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80103b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801041:	eb 30                	jmp    801073 <devcons_write+0x49>
		m = n - tot;
  801043:	8b 75 10             	mov    0x10(%ebp),%esi
  801046:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801048:	83 fe 7f             	cmp    $0x7f,%esi
  80104b:	76 05                	jbe    801052 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80104d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801052:	89 74 24 08          	mov    %esi,0x8(%esp)
  801056:	03 45 0c             	add    0xc(%ebp),%eax
  801059:	89 44 24 04          	mov    %eax,0x4(%esp)
  80105d:	89 3c 24             	mov    %edi,(%esp)
  801060:	e8 77 09 00 00       	call   8019dc <memmove>
		sys_cputs(buf, m);
  801065:	89 74 24 04          	mov    %esi,0x4(%esp)
  801069:	89 3c 24             	mov    %edi,(%esp)
  80106c:	e8 5b f0 ff ff       	call   8000cc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801071:	01 f3                	add    %esi,%ebx
  801073:	89 d8                	mov    %ebx,%eax
  801075:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801078:	72 c9                	jb     801043 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80107a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801080:	5b                   	pop    %ebx
  801081:	5e                   	pop    %esi
  801082:	5f                   	pop    %edi
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    

00801085 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80108b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80108f:	75 07                	jne    801098 <devcons_read+0x13>
  801091:	eb 25                	jmp    8010b8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801093:	e8 e2 f0 ff ff       	call   80017a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801098:	e8 4d f0 ff ff       	call   8000ea <sys_cgetc>
  80109d:	85 c0                	test   %eax,%eax
  80109f:	74 f2                	je     801093 <devcons_read+0xe>
  8010a1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	78 1d                	js     8010c4 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8010a7:	83 f8 04             	cmp    $0x4,%eax
  8010aa:	74 13                	je     8010bf <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8010ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010af:	88 10                	mov    %dl,(%eax)
	return 1;
  8010b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8010b6:	eb 0c                	jmp    8010c4 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8010b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010bd:	eb 05                	jmp    8010c4 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8010bf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8010c4:	c9                   	leave  
  8010c5:	c3                   	ret    

008010c6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8010cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8010d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010d9:	00 
  8010da:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010dd:	89 04 24             	mov    %eax,(%esp)
  8010e0:	e8 e7 ef ff ff       	call   8000cc <sys_cputs>
}
  8010e5:	c9                   	leave  
  8010e6:	c3                   	ret    

008010e7 <getchar>:

int
getchar(void)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8010ed:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010f4:	00 
  8010f5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801103:	e8 3a f6 ff ff       	call   800742 <read>
	if (r < 0)
  801108:	85 c0                	test   %eax,%eax
  80110a:	78 0f                	js     80111b <getchar+0x34>
		return r;
	if (r < 1)
  80110c:	85 c0                	test   %eax,%eax
  80110e:	7e 06                	jle    801116 <getchar+0x2f>
		return -E_EOF;
	return c;
  801110:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801114:	eb 05                	jmp    80111b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801116:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80111b:	c9                   	leave  
  80111c:	c3                   	ret    

0080111d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801123:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801126:	89 44 24 04          	mov    %eax,0x4(%esp)
  80112a:	8b 45 08             	mov    0x8(%ebp),%eax
  80112d:	89 04 24             	mov    %eax,(%esp)
  801130:	e8 71 f3 ff ff       	call   8004a6 <fd_lookup>
  801135:	85 c0                	test   %eax,%eax
  801137:	78 11                	js     80114a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801139:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801142:	39 10                	cmp    %edx,(%eax)
  801144:	0f 94 c0             	sete   %al
  801147:	0f b6 c0             	movzbl %al,%eax
}
  80114a:	c9                   	leave  
  80114b:	c3                   	ret    

0080114c <opencons>:

int
opencons(void)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801152:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801155:	89 04 24             	mov    %eax,(%esp)
  801158:	e8 f6 f2 ff ff       	call   800453 <fd_alloc>
  80115d:	85 c0                	test   %eax,%eax
  80115f:	78 3c                	js     80119d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801161:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801168:	00 
  801169:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801177:	e8 1d f0 ff ff       	call   800199 <sys_page_alloc>
  80117c:	85 c0                	test   %eax,%eax
  80117e:	78 1d                	js     80119d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801180:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801186:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801189:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80118b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801195:	89 04 24             	mov    %eax,(%esp)
  801198:	e8 8b f2 ff ff       	call   800428 <fd2num>
}
  80119d:	c9                   	leave  
  80119e:	c3                   	ret    
	...

008011a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	56                   	push   %esi
  8011a4:	53                   	push   %ebx
  8011a5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8011a8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011ab:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8011b1:	e8 a5 ef ff ff       	call   80015b <sys_getenvid>
  8011b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cc:	c7 04 24 20 21 80 00 	movl   $0x802120,(%esp)
  8011d3:	e8 c0 00 00 00       	call   801298 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8011df:	89 04 24             	mov    %eax,(%esp)
  8011e2:	e8 50 00 00 00       	call   801237 <vcprintf>
	cprintf("\n");
  8011e7:	c7 04 24 0d 21 80 00 	movl   $0x80210d,(%esp)
  8011ee:	e8 a5 00 00 00       	call   801298 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011f3:	cc                   	int3   
  8011f4:	eb fd                	jmp    8011f3 <_panic+0x53>
	...

008011f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	53                   	push   %ebx
  8011fc:	83 ec 14             	sub    $0x14,%esp
  8011ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801202:	8b 03                	mov    (%ebx),%eax
  801204:	8b 55 08             	mov    0x8(%ebp),%edx
  801207:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80120b:	40                   	inc    %eax
  80120c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80120e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801213:	75 19                	jne    80122e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801215:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80121c:	00 
  80121d:	8d 43 08             	lea    0x8(%ebx),%eax
  801220:	89 04 24             	mov    %eax,(%esp)
  801223:	e8 a4 ee ff ff       	call   8000cc <sys_cputs>
		b->idx = 0;
  801228:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80122e:	ff 43 04             	incl   0x4(%ebx)
}
  801231:	83 c4 14             	add    $0x14,%esp
  801234:	5b                   	pop    %ebx
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801240:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801247:	00 00 00 
	b.cnt = 0;
  80124a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801251:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801254:	8b 45 0c             	mov    0xc(%ebp),%eax
  801257:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80125b:	8b 45 08             	mov    0x8(%ebp),%eax
  80125e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801262:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126c:	c7 04 24 f8 11 80 00 	movl   $0x8011f8,(%esp)
  801273:	e8 82 01 00 00       	call   8013fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801278:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80127e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801282:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801288:	89 04 24             	mov    %eax,(%esp)
  80128b:	e8 3c ee ff ff       	call   8000cc <sys_cputs>

	return b.cnt;
}
  801290:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801296:	c9                   	leave  
  801297:	c3                   	ret    

00801298 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80129e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8012a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a8:	89 04 24             	mov    %eax,(%esp)
  8012ab:	e8 87 ff ff ff       	call   801237 <vcprintf>
	va_end(ap);

	return cnt;
}
  8012b0:	c9                   	leave  
  8012b1:	c3                   	ret    
	...

008012b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	57                   	push   %edi
  8012b8:	56                   	push   %esi
  8012b9:	53                   	push   %ebx
  8012ba:	83 ec 3c             	sub    $0x3c,%esp
  8012bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012c0:	89 d7                	mov    %edx,%edi
  8012c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8012c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8012d1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	75 08                	jne    8012e0 <printnum+0x2c>
  8012d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012db:	39 45 10             	cmp    %eax,0x10(%ebp)
  8012de:	77 57                	ja     801337 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8012e0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012e4:	4b                   	dec    %ebx
  8012e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8012ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8012f4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8012f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012ff:	00 
  801300:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801303:	89 04 24             	mov    %eax,(%esp)
  801306:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801309:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130d:	e8 72 0a 00 00       	call   801d84 <__udivdi3>
  801312:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801316:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80131a:	89 04 24             	mov    %eax,(%esp)
  80131d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801321:	89 fa                	mov    %edi,%edx
  801323:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801326:	e8 89 ff ff ff       	call   8012b4 <printnum>
  80132b:	eb 0f                	jmp    80133c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80132d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801331:	89 34 24             	mov    %esi,(%esp)
  801334:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801337:	4b                   	dec    %ebx
  801338:	85 db                	test   %ebx,%ebx
  80133a:	7f f1                	jg     80132d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80133c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801340:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801344:	8b 45 10             	mov    0x10(%ebp),%eax
  801347:	89 44 24 08          	mov    %eax,0x8(%esp)
  80134b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801352:	00 
  801353:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801356:	89 04 24             	mov    %eax,(%esp)
  801359:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80135c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801360:	e8 3f 0b 00 00       	call   801ea4 <__umoddi3>
  801365:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801369:	0f be 80 43 21 80 00 	movsbl 0x802143(%eax),%eax
  801370:	89 04 24             	mov    %eax,(%esp)
  801373:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801376:	83 c4 3c             	add    $0x3c,%esp
  801379:	5b                   	pop    %ebx
  80137a:	5e                   	pop    %esi
  80137b:	5f                   	pop    %edi
  80137c:	5d                   	pop    %ebp
  80137d:	c3                   	ret    

0080137e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801381:	83 fa 01             	cmp    $0x1,%edx
  801384:	7e 0e                	jle    801394 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801386:	8b 10                	mov    (%eax),%edx
  801388:	8d 4a 08             	lea    0x8(%edx),%ecx
  80138b:	89 08                	mov    %ecx,(%eax)
  80138d:	8b 02                	mov    (%edx),%eax
  80138f:	8b 52 04             	mov    0x4(%edx),%edx
  801392:	eb 22                	jmp    8013b6 <getuint+0x38>
	else if (lflag)
  801394:	85 d2                	test   %edx,%edx
  801396:	74 10                	je     8013a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801398:	8b 10                	mov    (%eax),%edx
  80139a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80139d:	89 08                	mov    %ecx,(%eax)
  80139f:	8b 02                	mov    (%edx),%eax
  8013a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a6:	eb 0e                	jmp    8013b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8013a8:	8b 10                	mov    (%eax),%edx
  8013aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013ad:	89 08                	mov    %ecx,(%eax)
  8013af:	8b 02                	mov    (%edx),%eax
  8013b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    

008013b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8013be:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8013c1:	8b 10                	mov    (%eax),%edx
  8013c3:	3b 50 04             	cmp    0x4(%eax),%edx
  8013c6:	73 08                	jae    8013d0 <sprintputch+0x18>
		*b->buf++ = ch;
  8013c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013cb:	88 0a                	mov    %cl,(%edx)
  8013cd:	42                   	inc    %edx
  8013ce:	89 10                	mov    %edx,(%eax)
}
  8013d0:	5d                   	pop    %ebp
  8013d1:	c3                   	ret    

008013d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8013d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8013db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013df:	8b 45 10             	mov    0x10(%ebp),%eax
  8013e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f0:	89 04 24             	mov    %eax,(%esp)
  8013f3:	e8 02 00 00 00       	call   8013fa <vprintfmt>
	va_end(ap);
}
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    

008013fa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	57                   	push   %edi
  8013fe:	56                   	push   %esi
  8013ff:	53                   	push   %ebx
  801400:	83 ec 4c             	sub    $0x4c,%esp
  801403:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801406:	8b 75 10             	mov    0x10(%ebp),%esi
  801409:	eb 12                	jmp    80141d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80140b:	85 c0                	test   %eax,%eax
  80140d:	0f 84 8b 03 00 00    	je     80179e <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  801413:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801417:	89 04 24             	mov    %eax,(%esp)
  80141a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80141d:	0f b6 06             	movzbl (%esi),%eax
  801420:	46                   	inc    %esi
  801421:	83 f8 25             	cmp    $0x25,%eax
  801424:	75 e5                	jne    80140b <vprintfmt+0x11>
  801426:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80142a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801431:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801436:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80143d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801442:	eb 26                	jmp    80146a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801444:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801447:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80144b:	eb 1d                	jmp    80146a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80144d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801450:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801454:	eb 14                	jmp    80146a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801456:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801459:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801460:	eb 08                	jmp    80146a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801462:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801465:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80146a:	0f b6 06             	movzbl (%esi),%eax
  80146d:	8d 56 01             	lea    0x1(%esi),%edx
  801470:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801473:	8a 16                	mov    (%esi),%dl
  801475:	83 ea 23             	sub    $0x23,%edx
  801478:	80 fa 55             	cmp    $0x55,%dl
  80147b:	0f 87 01 03 00 00    	ja     801782 <vprintfmt+0x388>
  801481:	0f b6 d2             	movzbl %dl,%edx
  801484:	ff 24 95 80 22 80 00 	jmp    *0x802280(,%edx,4)
  80148b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80148e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801493:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801496:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80149a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80149d:	8d 50 d0             	lea    -0x30(%eax),%edx
  8014a0:	83 fa 09             	cmp    $0x9,%edx
  8014a3:	77 2a                	ja     8014cf <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8014a5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8014a6:	eb eb                	jmp    801493 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8014a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ab:	8d 50 04             	lea    0x4(%eax),%edx
  8014ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8014b1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8014b6:	eb 17                	jmp    8014cf <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8014b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8014bc:	78 98                	js     801456 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014be:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8014c1:	eb a7                	jmp    80146a <vprintfmt+0x70>
  8014c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8014c6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8014cd:	eb 9b                	jmp    80146a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8014cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8014d3:	79 95                	jns    80146a <vprintfmt+0x70>
  8014d5:	eb 8b                	jmp    801462 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8014d7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8014db:	eb 8d                	jmp    80146a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8014dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e0:	8d 50 04             	lea    0x4(%eax),%edx
  8014e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8014e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ea:	8b 00                	mov    (%eax),%eax
  8014ec:	89 04 24             	mov    %eax,(%esp)
  8014ef:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8014f5:	e9 23 ff ff ff       	jmp    80141d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8014fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fd:	8d 50 04             	lea    0x4(%eax),%edx
  801500:	89 55 14             	mov    %edx,0x14(%ebp)
  801503:	8b 00                	mov    (%eax),%eax
  801505:	85 c0                	test   %eax,%eax
  801507:	79 02                	jns    80150b <vprintfmt+0x111>
  801509:	f7 d8                	neg    %eax
  80150b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80150d:	83 f8 0f             	cmp    $0xf,%eax
  801510:	7f 0b                	jg     80151d <vprintfmt+0x123>
  801512:	8b 04 85 e0 23 80 00 	mov    0x8023e0(,%eax,4),%eax
  801519:	85 c0                	test   %eax,%eax
  80151b:	75 23                	jne    801540 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80151d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801521:	c7 44 24 08 5b 21 80 	movl   $0x80215b,0x8(%esp)
  801528:	00 
  801529:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80152d:	8b 45 08             	mov    0x8(%ebp),%eax
  801530:	89 04 24             	mov    %eax,(%esp)
  801533:	e8 9a fe ff ff       	call   8013d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801538:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80153b:	e9 dd fe ff ff       	jmp    80141d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801540:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801544:	c7 44 24 08 e6 20 80 	movl   $0x8020e6,0x8(%esp)
  80154b:	00 
  80154c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801550:	8b 55 08             	mov    0x8(%ebp),%edx
  801553:	89 14 24             	mov    %edx,(%esp)
  801556:	e8 77 fe ff ff       	call   8013d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80155b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80155e:	e9 ba fe ff ff       	jmp    80141d <vprintfmt+0x23>
  801563:	89 f9                	mov    %edi,%ecx
  801565:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801568:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80156b:	8b 45 14             	mov    0x14(%ebp),%eax
  80156e:	8d 50 04             	lea    0x4(%eax),%edx
  801571:	89 55 14             	mov    %edx,0x14(%ebp)
  801574:	8b 30                	mov    (%eax),%esi
  801576:	85 f6                	test   %esi,%esi
  801578:	75 05                	jne    80157f <vprintfmt+0x185>
				p = "(null)";
  80157a:	be 54 21 80 00       	mov    $0x802154,%esi
			if (width > 0 && padc != '-')
  80157f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801583:	0f 8e 84 00 00 00    	jle    80160d <vprintfmt+0x213>
  801589:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80158d:	74 7e                	je     80160d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80158f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801593:	89 34 24             	mov    %esi,(%esp)
  801596:	e8 ab 02 00 00       	call   801846 <strnlen>
  80159b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80159e:	29 c2                	sub    %eax,%edx
  8015a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8015a3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8015a7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8015aa:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8015ad:	89 de                	mov    %ebx,%esi
  8015af:	89 d3                	mov    %edx,%ebx
  8015b1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8015b3:	eb 0b                	jmp    8015c0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8015b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015b9:	89 3c 24             	mov    %edi,(%esp)
  8015bc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8015bf:	4b                   	dec    %ebx
  8015c0:	85 db                	test   %ebx,%ebx
  8015c2:	7f f1                	jg     8015b5 <vprintfmt+0x1bb>
  8015c4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8015c7:	89 f3                	mov    %esi,%ebx
  8015c9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8015cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	79 05                	jns    8015d8 <vprintfmt+0x1de>
  8015d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015db:	29 c2                	sub    %eax,%edx
  8015dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8015e0:	eb 2b                	jmp    80160d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8015e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8015e6:	74 18                	je     801600 <vprintfmt+0x206>
  8015e8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8015eb:	83 fa 5e             	cmp    $0x5e,%edx
  8015ee:	76 10                	jbe    801600 <vprintfmt+0x206>
					putch('?', putdat);
  8015f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015f4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8015fb:	ff 55 08             	call   *0x8(%ebp)
  8015fe:	eb 0a                	jmp    80160a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801600:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801604:	89 04 24             	mov    %eax,(%esp)
  801607:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80160a:	ff 4d e4             	decl   -0x1c(%ebp)
  80160d:	0f be 06             	movsbl (%esi),%eax
  801610:	46                   	inc    %esi
  801611:	85 c0                	test   %eax,%eax
  801613:	74 21                	je     801636 <vprintfmt+0x23c>
  801615:	85 ff                	test   %edi,%edi
  801617:	78 c9                	js     8015e2 <vprintfmt+0x1e8>
  801619:	4f                   	dec    %edi
  80161a:	79 c6                	jns    8015e2 <vprintfmt+0x1e8>
  80161c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80161f:	89 de                	mov    %ebx,%esi
  801621:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801624:	eb 18                	jmp    80163e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801626:	89 74 24 04          	mov    %esi,0x4(%esp)
  80162a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801631:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801633:	4b                   	dec    %ebx
  801634:	eb 08                	jmp    80163e <vprintfmt+0x244>
  801636:	8b 7d 08             	mov    0x8(%ebp),%edi
  801639:	89 de                	mov    %ebx,%esi
  80163b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80163e:	85 db                	test   %ebx,%ebx
  801640:	7f e4                	jg     801626 <vprintfmt+0x22c>
  801642:	89 7d 08             	mov    %edi,0x8(%ebp)
  801645:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801647:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80164a:	e9 ce fd ff ff       	jmp    80141d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80164f:	83 f9 01             	cmp    $0x1,%ecx
  801652:	7e 10                	jle    801664 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801654:	8b 45 14             	mov    0x14(%ebp),%eax
  801657:	8d 50 08             	lea    0x8(%eax),%edx
  80165a:	89 55 14             	mov    %edx,0x14(%ebp)
  80165d:	8b 30                	mov    (%eax),%esi
  80165f:	8b 78 04             	mov    0x4(%eax),%edi
  801662:	eb 26                	jmp    80168a <vprintfmt+0x290>
	else if (lflag)
  801664:	85 c9                	test   %ecx,%ecx
  801666:	74 12                	je     80167a <vprintfmt+0x280>
		return va_arg(*ap, long);
  801668:	8b 45 14             	mov    0x14(%ebp),%eax
  80166b:	8d 50 04             	lea    0x4(%eax),%edx
  80166e:	89 55 14             	mov    %edx,0x14(%ebp)
  801671:	8b 30                	mov    (%eax),%esi
  801673:	89 f7                	mov    %esi,%edi
  801675:	c1 ff 1f             	sar    $0x1f,%edi
  801678:	eb 10                	jmp    80168a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80167a:	8b 45 14             	mov    0x14(%ebp),%eax
  80167d:	8d 50 04             	lea    0x4(%eax),%edx
  801680:	89 55 14             	mov    %edx,0x14(%ebp)
  801683:	8b 30                	mov    (%eax),%esi
  801685:	89 f7                	mov    %esi,%edi
  801687:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80168a:	85 ff                	test   %edi,%edi
  80168c:	78 0a                	js     801698 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80168e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801693:	e9 ac 00 00 00       	jmp    801744 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801698:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80169c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8016a3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8016a6:	f7 de                	neg    %esi
  8016a8:	83 d7 00             	adc    $0x0,%edi
  8016ab:	f7 df                	neg    %edi
			}
			base = 10;
  8016ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016b2:	e9 8d 00 00 00       	jmp    801744 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8016b7:	89 ca                	mov    %ecx,%edx
  8016b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8016bc:	e8 bd fc ff ff       	call   80137e <getuint>
  8016c1:	89 c6                	mov    %eax,%esi
  8016c3:	89 d7                	mov    %edx,%edi
			base = 10;
  8016c5:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8016ca:	eb 78                	jmp    801744 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8016cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8016d7:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8016da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016de:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8016e5:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8016e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016ec:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8016f3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8016f9:	e9 1f fd ff ff       	jmp    80141d <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8016fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801702:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801709:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80170c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801710:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801717:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80171a:	8b 45 14             	mov    0x14(%ebp),%eax
  80171d:	8d 50 04             	lea    0x4(%eax),%edx
  801720:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801723:	8b 30                	mov    (%eax),%esi
  801725:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80172a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80172f:	eb 13                	jmp    801744 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801731:	89 ca                	mov    %ecx,%edx
  801733:	8d 45 14             	lea    0x14(%ebp),%eax
  801736:	e8 43 fc ff ff       	call   80137e <getuint>
  80173b:	89 c6                	mov    %eax,%esi
  80173d:	89 d7                	mov    %edx,%edi
			base = 16;
  80173f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801744:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801748:	89 54 24 10          	mov    %edx,0x10(%esp)
  80174c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80174f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801753:	89 44 24 08          	mov    %eax,0x8(%esp)
  801757:	89 34 24             	mov    %esi,(%esp)
  80175a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80175e:	89 da                	mov    %ebx,%edx
  801760:	8b 45 08             	mov    0x8(%ebp),%eax
  801763:	e8 4c fb ff ff       	call   8012b4 <printnum>
			break;
  801768:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80176b:	e9 ad fc ff ff       	jmp    80141d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801770:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801774:	89 04 24             	mov    %eax,(%esp)
  801777:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80177a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80177d:	e9 9b fc ff ff       	jmp    80141d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801782:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801786:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80178d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801790:	eb 01                	jmp    801793 <vprintfmt+0x399>
  801792:	4e                   	dec    %esi
  801793:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801797:	75 f9                	jne    801792 <vprintfmt+0x398>
  801799:	e9 7f fc ff ff       	jmp    80141d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80179e:	83 c4 4c             	add    $0x4c,%esp
  8017a1:	5b                   	pop    %ebx
  8017a2:	5e                   	pop    %esi
  8017a3:	5f                   	pop    %edi
  8017a4:	5d                   	pop    %ebp
  8017a5:	c3                   	ret    

008017a6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	83 ec 28             	sub    $0x28,%esp
  8017ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8017af:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8017b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8017b5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8017b9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8017bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	74 30                	je     8017f7 <vsnprintf+0x51>
  8017c7:	85 d2                	test   %edx,%edx
  8017c9:	7e 33                	jle    8017fe <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8017cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8017d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8017dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e0:	c7 04 24 b8 13 80 00 	movl   $0x8013b8,(%esp)
  8017e7:	e8 0e fc ff ff       	call   8013fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8017ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8017ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8017f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f5:	eb 0c                	jmp    801803 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8017f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017fc:	eb 05                	jmp    801803 <vsnprintf+0x5d>
  8017fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801803:	c9                   	leave  
  801804:	c3                   	ret    

00801805 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80180b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80180e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801812:	8b 45 10             	mov    0x10(%ebp),%eax
  801815:	89 44 24 08          	mov    %eax,0x8(%esp)
  801819:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801820:	8b 45 08             	mov    0x8(%ebp),%eax
  801823:	89 04 24             	mov    %eax,(%esp)
  801826:	e8 7b ff ff ff       	call   8017a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80182b:	c9                   	leave  
  80182c:	c3                   	ret    
  80182d:	00 00                	add    %al,(%eax)
	...

00801830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801836:	b8 00 00 00 00       	mov    $0x0,%eax
  80183b:	eb 01                	jmp    80183e <strlen+0xe>
		n++;
  80183d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80183e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801842:	75 f9                	jne    80183d <strlen+0xd>
		n++;
	return n;
}
  801844:	5d                   	pop    %ebp
  801845:	c3                   	ret    

00801846 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80184c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80184f:	b8 00 00 00 00       	mov    $0x0,%eax
  801854:	eb 01                	jmp    801857 <strnlen+0x11>
		n++;
  801856:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801857:	39 d0                	cmp    %edx,%eax
  801859:	74 06                	je     801861 <strnlen+0x1b>
  80185b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80185f:	75 f5                	jne    801856 <strnlen+0x10>
		n++;
	return n;
}
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	53                   	push   %ebx
  801867:	8b 45 08             	mov    0x8(%ebp),%eax
  80186a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80186d:	ba 00 00 00 00       	mov    $0x0,%edx
  801872:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801875:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801878:	42                   	inc    %edx
  801879:	84 c9                	test   %cl,%cl
  80187b:	75 f5                	jne    801872 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80187d:	5b                   	pop    %ebx
  80187e:	5d                   	pop    %ebp
  80187f:	c3                   	ret    

00801880 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	53                   	push   %ebx
  801884:	83 ec 08             	sub    $0x8,%esp
  801887:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80188a:	89 1c 24             	mov    %ebx,(%esp)
  80188d:	e8 9e ff ff ff       	call   801830 <strlen>
	strcpy(dst + len, src);
  801892:	8b 55 0c             	mov    0xc(%ebp),%edx
  801895:	89 54 24 04          	mov    %edx,0x4(%esp)
  801899:	01 d8                	add    %ebx,%eax
  80189b:	89 04 24             	mov    %eax,(%esp)
  80189e:	e8 c0 ff ff ff       	call   801863 <strcpy>
	return dst;
}
  8018a3:	89 d8                	mov    %ebx,%eax
  8018a5:	83 c4 08             	add    $0x8,%esp
  8018a8:	5b                   	pop    %ebx
  8018a9:	5d                   	pop    %ebp
  8018aa:	c3                   	ret    

008018ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	56                   	push   %esi
  8018af:	53                   	push   %ebx
  8018b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8018b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018be:	eb 0c                	jmp    8018cc <strncpy+0x21>
		*dst++ = *src;
  8018c0:	8a 1a                	mov    (%edx),%bl
  8018c2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8018c5:	80 3a 01             	cmpb   $0x1,(%edx)
  8018c8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8018cb:	41                   	inc    %ecx
  8018cc:	39 f1                	cmp    %esi,%ecx
  8018ce:	75 f0                	jne    8018c0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8018d0:	5b                   	pop    %ebx
  8018d1:	5e                   	pop    %esi
  8018d2:	5d                   	pop    %ebp
  8018d3:	c3                   	ret    

008018d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	56                   	push   %esi
  8018d8:	53                   	push   %ebx
  8018d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8018dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018df:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8018e2:	85 d2                	test   %edx,%edx
  8018e4:	75 0a                	jne    8018f0 <strlcpy+0x1c>
  8018e6:	89 f0                	mov    %esi,%eax
  8018e8:	eb 1a                	jmp    801904 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8018ea:	88 18                	mov    %bl,(%eax)
  8018ec:	40                   	inc    %eax
  8018ed:	41                   	inc    %ecx
  8018ee:	eb 02                	jmp    8018f2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8018f0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8018f2:	4a                   	dec    %edx
  8018f3:	74 0a                	je     8018ff <strlcpy+0x2b>
  8018f5:	8a 19                	mov    (%ecx),%bl
  8018f7:	84 db                	test   %bl,%bl
  8018f9:	75 ef                	jne    8018ea <strlcpy+0x16>
  8018fb:	89 c2                	mov    %eax,%edx
  8018fd:	eb 02                	jmp    801901 <strlcpy+0x2d>
  8018ff:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801901:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801904:	29 f0                	sub    %esi,%eax
}
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801910:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801913:	eb 02                	jmp    801917 <strcmp+0xd>
		p++, q++;
  801915:	41                   	inc    %ecx
  801916:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801917:	8a 01                	mov    (%ecx),%al
  801919:	84 c0                	test   %al,%al
  80191b:	74 04                	je     801921 <strcmp+0x17>
  80191d:	3a 02                	cmp    (%edx),%al
  80191f:	74 f4                	je     801915 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801921:	0f b6 c0             	movzbl %al,%eax
  801924:	0f b6 12             	movzbl (%edx),%edx
  801927:	29 d0                	sub    %edx,%eax
}
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	53                   	push   %ebx
  80192f:	8b 45 08             	mov    0x8(%ebp),%eax
  801932:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801935:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801938:	eb 03                	jmp    80193d <strncmp+0x12>
		n--, p++, q++;
  80193a:	4a                   	dec    %edx
  80193b:	40                   	inc    %eax
  80193c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80193d:	85 d2                	test   %edx,%edx
  80193f:	74 14                	je     801955 <strncmp+0x2a>
  801941:	8a 18                	mov    (%eax),%bl
  801943:	84 db                	test   %bl,%bl
  801945:	74 04                	je     80194b <strncmp+0x20>
  801947:	3a 19                	cmp    (%ecx),%bl
  801949:	74 ef                	je     80193a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80194b:	0f b6 00             	movzbl (%eax),%eax
  80194e:	0f b6 11             	movzbl (%ecx),%edx
  801951:	29 d0                	sub    %edx,%eax
  801953:	eb 05                	jmp    80195a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801955:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80195a:	5b                   	pop    %ebx
  80195b:	5d                   	pop    %ebp
  80195c:	c3                   	ret    

0080195d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	8b 45 08             	mov    0x8(%ebp),%eax
  801963:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801966:	eb 05                	jmp    80196d <strchr+0x10>
		if (*s == c)
  801968:	38 ca                	cmp    %cl,%dl
  80196a:	74 0c                	je     801978 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80196c:	40                   	inc    %eax
  80196d:	8a 10                	mov    (%eax),%dl
  80196f:	84 d2                	test   %dl,%dl
  801971:	75 f5                	jne    801968 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801978:	5d                   	pop    %ebp
  801979:	c3                   	ret    

0080197a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	8b 45 08             	mov    0x8(%ebp),%eax
  801980:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801983:	eb 05                	jmp    80198a <strfind+0x10>
		if (*s == c)
  801985:	38 ca                	cmp    %cl,%dl
  801987:	74 07                	je     801990 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801989:	40                   	inc    %eax
  80198a:	8a 10                	mov    (%eax),%dl
  80198c:	84 d2                	test   %dl,%dl
  80198e:	75 f5                	jne    801985 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801990:	5d                   	pop    %ebp
  801991:	c3                   	ret    

00801992 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	57                   	push   %edi
  801996:	56                   	push   %esi
  801997:	53                   	push   %ebx
  801998:	8b 7d 08             	mov    0x8(%ebp),%edi
  80199b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8019a1:	85 c9                	test   %ecx,%ecx
  8019a3:	74 30                	je     8019d5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8019a5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019ab:	75 25                	jne    8019d2 <memset+0x40>
  8019ad:	f6 c1 03             	test   $0x3,%cl
  8019b0:	75 20                	jne    8019d2 <memset+0x40>
		c &= 0xFF;
  8019b2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8019b5:	89 d3                	mov    %edx,%ebx
  8019b7:	c1 e3 08             	shl    $0x8,%ebx
  8019ba:	89 d6                	mov    %edx,%esi
  8019bc:	c1 e6 18             	shl    $0x18,%esi
  8019bf:	89 d0                	mov    %edx,%eax
  8019c1:	c1 e0 10             	shl    $0x10,%eax
  8019c4:	09 f0                	or     %esi,%eax
  8019c6:	09 d0                	or     %edx,%eax
  8019c8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8019ca:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8019cd:	fc                   	cld    
  8019ce:	f3 ab                	rep stos %eax,%es:(%edi)
  8019d0:	eb 03                	jmp    8019d5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8019d2:	fc                   	cld    
  8019d3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8019d5:	89 f8                	mov    %edi,%eax
  8019d7:	5b                   	pop    %ebx
  8019d8:	5e                   	pop    %esi
  8019d9:	5f                   	pop    %edi
  8019da:	5d                   	pop    %ebp
  8019db:	c3                   	ret    

008019dc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	57                   	push   %edi
  8019e0:	56                   	push   %esi
  8019e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8019ea:	39 c6                	cmp    %eax,%esi
  8019ec:	73 34                	jae    801a22 <memmove+0x46>
  8019ee:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8019f1:	39 d0                	cmp    %edx,%eax
  8019f3:	73 2d                	jae    801a22 <memmove+0x46>
		s += n;
		d += n;
  8019f5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019f8:	f6 c2 03             	test   $0x3,%dl
  8019fb:	75 1b                	jne    801a18 <memmove+0x3c>
  8019fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801a03:	75 13                	jne    801a18 <memmove+0x3c>
  801a05:	f6 c1 03             	test   $0x3,%cl
  801a08:	75 0e                	jne    801a18 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a0a:	83 ef 04             	sub    $0x4,%edi
  801a0d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a10:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801a13:	fd                   	std    
  801a14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a16:	eb 07                	jmp    801a1f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a18:	4f                   	dec    %edi
  801a19:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801a1c:	fd                   	std    
  801a1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801a1f:	fc                   	cld    
  801a20:	eb 20                	jmp    801a42 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a22:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a28:	75 13                	jne    801a3d <memmove+0x61>
  801a2a:	a8 03                	test   $0x3,%al
  801a2c:	75 0f                	jne    801a3d <memmove+0x61>
  801a2e:	f6 c1 03             	test   $0x3,%cl
  801a31:	75 0a                	jne    801a3d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a33:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801a36:	89 c7                	mov    %eax,%edi
  801a38:	fc                   	cld    
  801a39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a3b:	eb 05                	jmp    801a42 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801a3d:	89 c7                	mov    %eax,%edi
  801a3f:	fc                   	cld    
  801a40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a42:	5e                   	pop    %esi
  801a43:	5f                   	pop    %edi
  801a44:	5d                   	pop    %ebp
  801a45:	c3                   	ret    

00801a46 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a4c:	8b 45 10             	mov    0x10(%ebp),%eax
  801a4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a56:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5d:	89 04 24             	mov    %eax,(%esp)
  801a60:	e8 77 ff ff ff       	call   8019dc <memmove>
}
  801a65:	c9                   	leave  
  801a66:	c3                   	ret    

00801a67 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	57                   	push   %edi
  801a6b:	56                   	push   %esi
  801a6c:	53                   	push   %ebx
  801a6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a70:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a76:	ba 00 00 00 00       	mov    $0x0,%edx
  801a7b:	eb 16                	jmp    801a93 <memcmp+0x2c>
		if (*s1 != *s2)
  801a7d:	8a 04 17             	mov    (%edi,%edx,1),%al
  801a80:	42                   	inc    %edx
  801a81:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801a85:	38 c8                	cmp    %cl,%al
  801a87:	74 0a                	je     801a93 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801a89:	0f b6 c0             	movzbl %al,%eax
  801a8c:	0f b6 c9             	movzbl %cl,%ecx
  801a8f:	29 c8                	sub    %ecx,%eax
  801a91:	eb 09                	jmp    801a9c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a93:	39 da                	cmp    %ebx,%edx
  801a95:	75 e6                	jne    801a7d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801a97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a9c:	5b                   	pop    %ebx
  801a9d:	5e                   	pop    %esi
  801a9e:	5f                   	pop    %edi
  801a9f:	5d                   	pop    %ebp
  801aa0:	c3                   	ret    

00801aa1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801aaa:	89 c2                	mov    %eax,%edx
  801aac:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801aaf:	eb 05                	jmp    801ab6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ab1:	38 08                	cmp    %cl,(%eax)
  801ab3:	74 05                	je     801aba <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ab5:	40                   	inc    %eax
  801ab6:	39 d0                	cmp    %edx,%eax
  801ab8:	72 f7                	jb     801ab1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	57                   	push   %edi
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
  801ac2:	8b 55 08             	mov    0x8(%ebp),%edx
  801ac5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ac8:	eb 01                	jmp    801acb <strtol+0xf>
		s++;
  801aca:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801acb:	8a 02                	mov    (%edx),%al
  801acd:	3c 20                	cmp    $0x20,%al
  801acf:	74 f9                	je     801aca <strtol+0xe>
  801ad1:	3c 09                	cmp    $0x9,%al
  801ad3:	74 f5                	je     801aca <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ad5:	3c 2b                	cmp    $0x2b,%al
  801ad7:	75 08                	jne    801ae1 <strtol+0x25>
		s++;
  801ad9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ada:	bf 00 00 00 00       	mov    $0x0,%edi
  801adf:	eb 13                	jmp    801af4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ae1:	3c 2d                	cmp    $0x2d,%al
  801ae3:	75 0a                	jne    801aef <strtol+0x33>
		s++, neg = 1;
  801ae5:	8d 52 01             	lea    0x1(%edx),%edx
  801ae8:	bf 01 00 00 00       	mov    $0x1,%edi
  801aed:	eb 05                	jmp    801af4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801aef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801af4:	85 db                	test   %ebx,%ebx
  801af6:	74 05                	je     801afd <strtol+0x41>
  801af8:	83 fb 10             	cmp    $0x10,%ebx
  801afb:	75 28                	jne    801b25 <strtol+0x69>
  801afd:	8a 02                	mov    (%edx),%al
  801aff:	3c 30                	cmp    $0x30,%al
  801b01:	75 10                	jne    801b13 <strtol+0x57>
  801b03:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b07:	75 0a                	jne    801b13 <strtol+0x57>
		s += 2, base = 16;
  801b09:	83 c2 02             	add    $0x2,%edx
  801b0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801b11:	eb 12                	jmp    801b25 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801b13:	85 db                	test   %ebx,%ebx
  801b15:	75 0e                	jne    801b25 <strtol+0x69>
  801b17:	3c 30                	cmp    $0x30,%al
  801b19:	75 05                	jne    801b20 <strtol+0x64>
		s++, base = 8;
  801b1b:	42                   	inc    %edx
  801b1c:	b3 08                	mov    $0x8,%bl
  801b1e:	eb 05                	jmp    801b25 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801b20:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801b25:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801b2c:	8a 0a                	mov    (%edx),%cl
  801b2e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801b31:	80 fb 09             	cmp    $0x9,%bl
  801b34:	77 08                	ja     801b3e <strtol+0x82>
			dig = *s - '0';
  801b36:	0f be c9             	movsbl %cl,%ecx
  801b39:	83 e9 30             	sub    $0x30,%ecx
  801b3c:	eb 1e                	jmp    801b5c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801b3e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801b41:	80 fb 19             	cmp    $0x19,%bl
  801b44:	77 08                	ja     801b4e <strtol+0x92>
			dig = *s - 'a' + 10;
  801b46:	0f be c9             	movsbl %cl,%ecx
  801b49:	83 e9 57             	sub    $0x57,%ecx
  801b4c:	eb 0e                	jmp    801b5c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801b4e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801b51:	80 fb 19             	cmp    $0x19,%bl
  801b54:	77 12                	ja     801b68 <strtol+0xac>
			dig = *s - 'A' + 10;
  801b56:	0f be c9             	movsbl %cl,%ecx
  801b59:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801b5c:	39 f1                	cmp    %esi,%ecx
  801b5e:	7d 0c                	jge    801b6c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801b60:	42                   	inc    %edx
  801b61:	0f af c6             	imul   %esi,%eax
  801b64:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801b66:	eb c4                	jmp    801b2c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801b68:	89 c1                	mov    %eax,%ecx
  801b6a:	eb 02                	jmp    801b6e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801b6c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801b6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b72:	74 05                	je     801b79 <strtol+0xbd>
		*endptr = (char *) s;
  801b74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b77:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801b79:	85 ff                	test   %edi,%edi
  801b7b:	74 04                	je     801b81 <strtol+0xc5>
  801b7d:	89 c8                	mov    %ecx,%eax
  801b7f:	f7 d8                	neg    %eax
}
  801b81:	5b                   	pop    %ebx
  801b82:	5e                   	pop    %esi
  801b83:	5f                   	pop    %edi
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    
	...

00801b88 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801b8e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801b95:	0f 85 80 00 00 00    	jne    801c1b <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  801b9b:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba0:	8b 40 48             	mov    0x48(%eax),%eax
  801ba3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801baa:	00 
  801bab:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801bb2:	ee 
  801bb3:	89 04 24             	mov    %eax,(%esp)
  801bb6:	e8 de e5 ff ff       	call   800199 <sys_page_alloc>
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	79 20                	jns    801bdf <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  801bbf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bc3:	c7 44 24 08 40 24 80 	movl   $0x802440,0x8(%esp)
  801bca:	00 
  801bcb:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801bd2:	00 
  801bd3:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  801bda:	e8 c1 f5 ff ff       	call   8011a0 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  801bdf:	a1 04 40 80 00       	mov    0x804004,%eax
  801be4:	8b 40 48             	mov    0x48(%eax),%eax
  801be7:	c7 44 24 04 04 04 80 	movl   $0x800404,0x4(%esp)
  801bee:	00 
  801bef:	89 04 24             	mov    %eax,(%esp)
  801bf2:	e8 42 e7 ff ff       	call   800339 <sys_env_set_pgfault_upcall>
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	79 20                	jns    801c1b <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  801bfb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bff:	c7 44 24 08 6c 24 80 	movl   $0x80246c,0x8(%esp)
  801c06:	00 
  801c07:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801c0e:	00 
  801c0f:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  801c16:	e8 85 f5 ff ff       	call   8011a0 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801c23:	c9                   	leave  
  801c24:	c3                   	ret    
  801c25:	00 00                	add    %al,(%eax)
	...

00801c28 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	56                   	push   %esi
  801c2c:	53                   	push   %ebx
  801c2d:	83 ec 10             	sub    $0x10,%esp
  801c30:	8b 75 08             	mov    0x8(%ebp),%esi
  801c33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	75 05                	jne    801c42 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801c3d:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801c42:	89 04 24             	mov    %eax,(%esp)
  801c45:	e8 65 e7 ff ff       	call   8003af <sys_ipc_recv>
	if (!err) {
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	75 26                	jne    801c74 <ipc_recv+0x4c>
		if (from_env_store) {
  801c4e:	85 f6                	test   %esi,%esi
  801c50:	74 0a                	je     801c5c <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801c52:	a1 04 40 80 00       	mov    0x804004,%eax
  801c57:	8b 40 74             	mov    0x74(%eax),%eax
  801c5a:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801c5c:	85 db                	test   %ebx,%ebx
  801c5e:	74 0a                	je     801c6a <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801c60:	a1 04 40 80 00       	mov    0x804004,%eax
  801c65:	8b 40 78             	mov    0x78(%eax),%eax
  801c68:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801c6a:	a1 04 40 80 00       	mov    0x804004,%eax
  801c6f:	8b 40 70             	mov    0x70(%eax),%eax
  801c72:	eb 14                	jmp    801c88 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801c74:	85 f6                	test   %esi,%esi
  801c76:	74 06                	je     801c7e <ipc_recv+0x56>
		*from_env_store = 0;
  801c78:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801c7e:	85 db                	test   %ebx,%ebx
  801c80:	74 06                	je     801c88 <ipc_recv+0x60>
		*perm_store = 0;
  801c82:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	5b                   	pop    %ebx
  801c8c:	5e                   	pop    %esi
  801c8d:	5d                   	pop    %ebp
  801c8e:	c3                   	ret    

00801c8f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	57                   	push   %edi
  801c93:	56                   	push   %esi
  801c94:	53                   	push   %ebx
  801c95:	83 ec 1c             	sub    $0x1c,%esp
  801c98:	8b 75 10             	mov    0x10(%ebp),%esi
  801c9b:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801c9e:	85 f6                	test   %esi,%esi
  801ca0:	75 05                	jne    801ca7 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801ca2:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801ca7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801cab:	89 74 24 08          	mov    %esi,0x8(%esp)
  801caf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb9:	89 04 24             	mov    %eax,(%esp)
  801cbc:	e8 cb e6 ff ff       	call   80038c <sys_ipc_try_send>
  801cc1:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801cc3:	e8 b2 e4 ff ff       	call   80017a <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801cc8:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801ccb:	74 da                	je     801ca7 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801ccd:	85 db                	test   %ebx,%ebx
  801ccf:	74 20                	je     801cf1 <ipc_send+0x62>
		panic("send fail: %e", err);
  801cd1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801cd5:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  801cdc:	00 
  801cdd:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801ce4:	00 
  801ce5:	c7 04 24 b8 24 80 00 	movl   $0x8024b8,(%esp)
  801cec:	e8 af f4 ff ff       	call   8011a0 <_panic>
	}
	return;
}
  801cf1:	83 c4 1c             	add    $0x1c,%esp
  801cf4:	5b                   	pop    %ebx
  801cf5:	5e                   	pop    %esi
  801cf6:	5f                   	pop    %edi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    

00801cf9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	53                   	push   %ebx
  801cfd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801d00:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d05:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801d0c:	89 c2                	mov    %eax,%edx
  801d0e:	c1 e2 07             	shl    $0x7,%edx
  801d11:	29 ca                	sub    %ecx,%edx
  801d13:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d19:	8b 52 50             	mov    0x50(%edx),%edx
  801d1c:	39 da                	cmp    %ebx,%edx
  801d1e:	75 0f                	jne    801d2f <ipc_find_env+0x36>
			return envs[i].env_id;
  801d20:	c1 e0 07             	shl    $0x7,%eax
  801d23:	29 c8                	sub    %ecx,%eax
  801d25:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d2a:	8b 40 40             	mov    0x40(%eax),%eax
  801d2d:	eb 0c                	jmp    801d3b <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d2f:	40                   	inc    %eax
  801d30:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d35:	75 ce                	jne    801d05 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d37:	66 b8 00 00          	mov    $0x0,%ax
}
  801d3b:	5b                   	pop    %ebx
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    
	...

00801d40 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d46:	89 c2                	mov    %eax,%edx
  801d48:	c1 ea 16             	shr    $0x16,%edx
  801d4b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d52:	f6 c2 01             	test   $0x1,%dl
  801d55:	74 1e                	je     801d75 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d57:	c1 e8 0c             	shr    $0xc,%eax
  801d5a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d61:	a8 01                	test   $0x1,%al
  801d63:	74 17                	je     801d7c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d65:	c1 e8 0c             	shr    $0xc,%eax
  801d68:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d6f:	ef 
  801d70:	0f b7 c0             	movzwl %ax,%eax
  801d73:	eb 0c                	jmp    801d81 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d75:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7a:	eb 05                	jmp    801d81 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d7c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    
	...

00801d84 <__udivdi3>:
  801d84:	55                   	push   %ebp
  801d85:	57                   	push   %edi
  801d86:	56                   	push   %esi
  801d87:	83 ec 10             	sub    $0x10,%esp
  801d8a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d8e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801d92:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d96:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d9a:	89 cd                	mov    %ecx,%ebp
  801d9c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801da0:	85 c0                	test   %eax,%eax
  801da2:	75 2c                	jne    801dd0 <__udivdi3+0x4c>
  801da4:	39 f9                	cmp    %edi,%ecx
  801da6:	77 68                	ja     801e10 <__udivdi3+0x8c>
  801da8:	85 c9                	test   %ecx,%ecx
  801daa:	75 0b                	jne    801db7 <__udivdi3+0x33>
  801dac:	b8 01 00 00 00       	mov    $0x1,%eax
  801db1:	31 d2                	xor    %edx,%edx
  801db3:	f7 f1                	div    %ecx
  801db5:	89 c1                	mov    %eax,%ecx
  801db7:	31 d2                	xor    %edx,%edx
  801db9:	89 f8                	mov    %edi,%eax
  801dbb:	f7 f1                	div    %ecx
  801dbd:	89 c7                	mov    %eax,%edi
  801dbf:	89 f0                	mov    %esi,%eax
  801dc1:	f7 f1                	div    %ecx
  801dc3:	89 c6                	mov    %eax,%esi
  801dc5:	89 f0                	mov    %esi,%eax
  801dc7:	89 fa                	mov    %edi,%edx
  801dc9:	83 c4 10             	add    $0x10,%esp
  801dcc:	5e                   	pop    %esi
  801dcd:	5f                   	pop    %edi
  801dce:	5d                   	pop    %ebp
  801dcf:	c3                   	ret    
  801dd0:	39 f8                	cmp    %edi,%eax
  801dd2:	77 2c                	ja     801e00 <__udivdi3+0x7c>
  801dd4:	0f bd f0             	bsr    %eax,%esi
  801dd7:	83 f6 1f             	xor    $0x1f,%esi
  801dda:	75 4c                	jne    801e28 <__udivdi3+0xa4>
  801ddc:	39 f8                	cmp    %edi,%eax
  801dde:	bf 00 00 00 00       	mov    $0x0,%edi
  801de3:	72 0a                	jb     801def <__udivdi3+0x6b>
  801de5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801de9:	0f 87 ad 00 00 00    	ja     801e9c <__udivdi3+0x118>
  801def:	be 01 00 00 00       	mov    $0x1,%esi
  801df4:	89 f0                	mov    %esi,%eax
  801df6:	89 fa                	mov    %edi,%edx
  801df8:	83 c4 10             	add    $0x10,%esp
  801dfb:	5e                   	pop    %esi
  801dfc:	5f                   	pop    %edi
  801dfd:	5d                   	pop    %ebp
  801dfe:	c3                   	ret    
  801dff:	90                   	nop
  801e00:	31 ff                	xor    %edi,%edi
  801e02:	31 f6                	xor    %esi,%esi
  801e04:	89 f0                	mov    %esi,%eax
  801e06:	89 fa                	mov    %edi,%edx
  801e08:	83 c4 10             	add    $0x10,%esp
  801e0b:	5e                   	pop    %esi
  801e0c:	5f                   	pop    %edi
  801e0d:	5d                   	pop    %ebp
  801e0e:	c3                   	ret    
  801e0f:	90                   	nop
  801e10:	89 fa                	mov    %edi,%edx
  801e12:	89 f0                	mov    %esi,%eax
  801e14:	f7 f1                	div    %ecx
  801e16:	89 c6                	mov    %eax,%esi
  801e18:	31 ff                	xor    %edi,%edi
  801e1a:	89 f0                	mov    %esi,%eax
  801e1c:	89 fa                	mov    %edi,%edx
  801e1e:	83 c4 10             	add    $0x10,%esp
  801e21:	5e                   	pop    %esi
  801e22:	5f                   	pop    %edi
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    
  801e25:	8d 76 00             	lea    0x0(%esi),%esi
  801e28:	89 f1                	mov    %esi,%ecx
  801e2a:	d3 e0                	shl    %cl,%eax
  801e2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e30:	b8 20 00 00 00       	mov    $0x20,%eax
  801e35:	29 f0                	sub    %esi,%eax
  801e37:	89 ea                	mov    %ebp,%edx
  801e39:	88 c1                	mov    %al,%cl
  801e3b:	d3 ea                	shr    %cl,%edx
  801e3d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801e41:	09 ca                	or     %ecx,%edx
  801e43:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e47:	89 f1                	mov    %esi,%ecx
  801e49:	d3 e5                	shl    %cl,%ebp
  801e4b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801e4f:	89 fd                	mov    %edi,%ebp
  801e51:	88 c1                	mov    %al,%cl
  801e53:	d3 ed                	shr    %cl,%ebp
  801e55:	89 fa                	mov    %edi,%edx
  801e57:	89 f1                	mov    %esi,%ecx
  801e59:	d3 e2                	shl    %cl,%edx
  801e5b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e5f:	88 c1                	mov    %al,%cl
  801e61:	d3 ef                	shr    %cl,%edi
  801e63:	09 d7                	or     %edx,%edi
  801e65:	89 f8                	mov    %edi,%eax
  801e67:	89 ea                	mov    %ebp,%edx
  801e69:	f7 74 24 08          	divl   0x8(%esp)
  801e6d:	89 d1                	mov    %edx,%ecx
  801e6f:	89 c7                	mov    %eax,%edi
  801e71:	f7 64 24 0c          	mull   0xc(%esp)
  801e75:	39 d1                	cmp    %edx,%ecx
  801e77:	72 17                	jb     801e90 <__udivdi3+0x10c>
  801e79:	74 09                	je     801e84 <__udivdi3+0x100>
  801e7b:	89 fe                	mov    %edi,%esi
  801e7d:	31 ff                	xor    %edi,%edi
  801e7f:	e9 41 ff ff ff       	jmp    801dc5 <__udivdi3+0x41>
  801e84:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e88:	89 f1                	mov    %esi,%ecx
  801e8a:	d3 e2                	shl    %cl,%edx
  801e8c:	39 c2                	cmp    %eax,%edx
  801e8e:	73 eb                	jae    801e7b <__udivdi3+0xf7>
  801e90:	8d 77 ff             	lea    -0x1(%edi),%esi
  801e93:	31 ff                	xor    %edi,%edi
  801e95:	e9 2b ff ff ff       	jmp    801dc5 <__udivdi3+0x41>
  801e9a:	66 90                	xchg   %ax,%ax
  801e9c:	31 f6                	xor    %esi,%esi
  801e9e:	e9 22 ff ff ff       	jmp    801dc5 <__udivdi3+0x41>
	...

00801ea4 <__umoddi3>:
  801ea4:	55                   	push   %ebp
  801ea5:	57                   	push   %edi
  801ea6:	56                   	push   %esi
  801ea7:	83 ec 20             	sub    $0x20,%esp
  801eaa:	8b 44 24 30          	mov    0x30(%esp),%eax
  801eae:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801eb2:	89 44 24 14          	mov    %eax,0x14(%esp)
  801eb6:	8b 74 24 34          	mov    0x34(%esp),%esi
  801eba:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ebe:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801ec2:	89 c7                	mov    %eax,%edi
  801ec4:	89 f2                	mov    %esi,%edx
  801ec6:	85 ed                	test   %ebp,%ebp
  801ec8:	75 16                	jne    801ee0 <__umoddi3+0x3c>
  801eca:	39 f1                	cmp    %esi,%ecx
  801ecc:	0f 86 a6 00 00 00    	jbe    801f78 <__umoddi3+0xd4>
  801ed2:	f7 f1                	div    %ecx
  801ed4:	89 d0                	mov    %edx,%eax
  801ed6:	31 d2                	xor    %edx,%edx
  801ed8:	83 c4 20             	add    $0x20,%esp
  801edb:	5e                   	pop    %esi
  801edc:	5f                   	pop    %edi
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    
  801edf:	90                   	nop
  801ee0:	39 f5                	cmp    %esi,%ebp
  801ee2:	0f 87 ac 00 00 00    	ja     801f94 <__umoddi3+0xf0>
  801ee8:	0f bd c5             	bsr    %ebp,%eax
  801eeb:	83 f0 1f             	xor    $0x1f,%eax
  801eee:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ef2:	0f 84 a8 00 00 00    	je     801fa0 <__umoddi3+0xfc>
  801ef8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801efc:	d3 e5                	shl    %cl,%ebp
  801efe:	bf 20 00 00 00       	mov    $0x20,%edi
  801f03:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801f07:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f0b:	89 f9                	mov    %edi,%ecx
  801f0d:	d3 e8                	shr    %cl,%eax
  801f0f:	09 e8                	or     %ebp,%eax
  801f11:	89 44 24 18          	mov    %eax,0x18(%esp)
  801f15:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f19:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f1d:	d3 e0                	shl    %cl,%eax
  801f1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f23:	89 f2                	mov    %esi,%edx
  801f25:	d3 e2                	shl    %cl,%edx
  801f27:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f2b:	d3 e0                	shl    %cl,%eax
  801f2d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801f31:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f35:	89 f9                	mov    %edi,%ecx
  801f37:	d3 e8                	shr    %cl,%eax
  801f39:	09 d0                	or     %edx,%eax
  801f3b:	d3 ee                	shr    %cl,%esi
  801f3d:	89 f2                	mov    %esi,%edx
  801f3f:	f7 74 24 18          	divl   0x18(%esp)
  801f43:	89 d6                	mov    %edx,%esi
  801f45:	f7 64 24 0c          	mull   0xc(%esp)
  801f49:	89 c5                	mov    %eax,%ebp
  801f4b:	89 d1                	mov    %edx,%ecx
  801f4d:	39 d6                	cmp    %edx,%esi
  801f4f:	72 67                	jb     801fb8 <__umoddi3+0x114>
  801f51:	74 75                	je     801fc8 <__umoddi3+0x124>
  801f53:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f57:	29 e8                	sub    %ebp,%eax
  801f59:	19 ce                	sbb    %ecx,%esi
  801f5b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f5f:	d3 e8                	shr    %cl,%eax
  801f61:	89 f2                	mov    %esi,%edx
  801f63:	89 f9                	mov    %edi,%ecx
  801f65:	d3 e2                	shl    %cl,%edx
  801f67:	09 d0                	or     %edx,%eax
  801f69:	89 f2                	mov    %esi,%edx
  801f6b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f6f:	d3 ea                	shr    %cl,%edx
  801f71:	83 c4 20             	add    $0x20,%esp
  801f74:	5e                   	pop    %esi
  801f75:	5f                   	pop    %edi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    
  801f78:	85 c9                	test   %ecx,%ecx
  801f7a:	75 0b                	jne    801f87 <__umoddi3+0xe3>
  801f7c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f81:	31 d2                	xor    %edx,%edx
  801f83:	f7 f1                	div    %ecx
  801f85:	89 c1                	mov    %eax,%ecx
  801f87:	89 f0                	mov    %esi,%eax
  801f89:	31 d2                	xor    %edx,%edx
  801f8b:	f7 f1                	div    %ecx
  801f8d:	89 f8                	mov    %edi,%eax
  801f8f:	e9 3e ff ff ff       	jmp    801ed2 <__umoddi3+0x2e>
  801f94:	89 f2                	mov    %esi,%edx
  801f96:	83 c4 20             	add    $0x20,%esp
  801f99:	5e                   	pop    %esi
  801f9a:	5f                   	pop    %edi
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    
  801f9d:	8d 76 00             	lea    0x0(%esi),%esi
  801fa0:	39 f5                	cmp    %esi,%ebp
  801fa2:	72 04                	jb     801fa8 <__umoddi3+0x104>
  801fa4:	39 f9                	cmp    %edi,%ecx
  801fa6:	77 06                	ja     801fae <__umoddi3+0x10a>
  801fa8:	89 f2                	mov    %esi,%edx
  801faa:	29 cf                	sub    %ecx,%edi
  801fac:	19 ea                	sbb    %ebp,%edx
  801fae:	89 f8                	mov    %edi,%eax
  801fb0:	83 c4 20             	add    $0x20,%esp
  801fb3:	5e                   	pop    %esi
  801fb4:	5f                   	pop    %edi
  801fb5:	5d                   	pop    %ebp
  801fb6:	c3                   	ret    
  801fb7:	90                   	nop
  801fb8:	89 d1                	mov    %edx,%ecx
  801fba:	89 c5                	mov    %eax,%ebp
  801fbc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801fc0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801fc4:	eb 8d                	jmp    801f53 <__umoddi3+0xaf>
  801fc6:	66 90                	xchg   %ax,%ax
  801fc8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801fcc:	72 ea                	jb     801fb8 <__umoddi3+0x114>
  801fce:	89 f1                	mov    %esi,%ecx
  801fd0:	eb 81                	jmp    801f53 <__umoddi3+0xaf>

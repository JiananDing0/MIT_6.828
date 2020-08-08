
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
	sys_cputs((char*)1, 1);
  80003a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800049:	e8 72 00 00 00       	call   8000c0 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 75 08             	mov    0x8(%ebp),%esi
  80005b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80005e:	e8 ec 00 00 00       	call   80014f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006f:	c1 e0 07             	shl    $0x7,%eax
  800072:	29 d0                	sub    %edx,%eax
  800074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800079:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 f6                	test   %esi,%esi
  800080:	7e 07                	jle    800089 <libmain+0x39>
		binaryname = argv[0];
  800082:	8b 03                	mov    (%ebx),%eax
  800084:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800089:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008d:	89 34 24             	mov    %esi,(%esp)
  800090:	e8 9f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5e                   	pop    %esi
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    
  8000a1:	00 00                	add    %al,(%eax)
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000aa:	e8 30 05 00 00       	call   8005df <close_all>
	sys_env_destroy(0);
  8000af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b6:	e8 42 00 00 00       	call   8000fd <sys_env_destroy>
}
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    
  8000bd:	00 00                	add    %al,(%eax)
	...

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d1:	89 c3                	mov    %eax,%ebx
  8000d3:	89 c7                	mov    %eax,%edi
  8000d5:	89 c6                	mov    %eax,%esi
  8000d7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <sys_cgetc>:

int
sys_cgetc(void)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	57                   	push   %edi
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ee:	89 d1                	mov    %edx,%ecx
  8000f0:	89 d3                	mov    %edx,%ebx
  8000f2:	89 d7                	mov    %edx,%edi
  8000f4:	89 d6                	mov    %edx,%esi
  8000f6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    

008000fd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	57                   	push   %edi
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800106:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010b:	b8 03 00 00 00       	mov    $0x3,%eax
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	89 cb                	mov    %ecx,%ebx
  800115:	89 cf                	mov    %ecx,%edi
  800117:	89 ce                	mov    %ecx,%esi
  800119:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80011b:	85 c0                	test   %eax,%eax
  80011d:	7e 28                	jle    800147 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800123:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80012a:	00 
  80012b:	c7 44 24 08 2a 1f 80 	movl   $0x801f2a,0x8(%esp)
  800132:	00 
  800133:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80013a:	00 
  80013b:	c7 04 24 47 1f 80 00 	movl   $0x801f47,(%esp)
  800142:	e8 29 10 00 00       	call   801170 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800147:	83 c4 2c             	add    $0x2c,%esp
  80014a:	5b                   	pop    %ebx
  80014b:	5e                   	pop    %esi
  80014c:	5f                   	pop    %edi
  80014d:	5d                   	pop    %ebp
  80014e:	c3                   	ret    

0080014f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800155:	ba 00 00 00 00       	mov    $0x0,%edx
  80015a:	b8 02 00 00 00       	mov    $0x2,%eax
  80015f:	89 d1                	mov    %edx,%ecx
  800161:	89 d3                	mov    %edx,%ebx
  800163:	89 d7                	mov    %edx,%edi
  800165:	89 d6                	mov    %edx,%esi
  800167:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800169:	5b                   	pop    %ebx
  80016a:	5e                   	pop    %esi
  80016b:	5f                   	pop    %edi
  80016c:	5d                   	pop    %ebp
  80016d:	c3                   	ret    

0080016e <sys_yield>:

void
sys_yield(void)
{
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	57                   	push   %edi
  800172:	56                   	push   %esi
  800173:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800174:	ba 00 00 00 00       	mov    $0x0,%edx
  800179:	b8 0b 00 00 00       	mov    $0xb,%eax
  80017e:	89 d1                	mov    %edx,%ecx
  800180:	89 d3                	mov    %edx,%ebx
  800182:	89 d7                	mov    %edx,%edi
  800184:	89 d6                	mov    %edx,%esi
  800186:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800188:	5b                   	pop    %ebx
  800189:	5e                   	pop    %esi
  80018a:	5f                   	pop    %edi
  80018b:	5d                   	pop    %ebp
  80018c:	c3                   	ret    

0080018d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	57                   	push   %edi
  800191:	56                   	push   %esi
  800192:	53                   	push   %ebx
  800193:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800196:	be 00 00 00 00       	mov    $0x0,%esi
  80019b:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	89 f7                	mov    %esi,%edi
  8001ab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ad:	85 c0                	test   %eax,%eax
  8001af:	7e 28                	jle    8001d9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001bc:	00 
  8001bd:	c7 44 24 08 2a 1f 80 	movl   $0x801f2a,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001cc:	00 
  8001cd:	c7 04 24 47 1f 80 00 	movl   $0x801f47,(%esp)
  8001d4:	e8 97 0f 00 00       	call   801170 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d9:	83 c4 2c             	add    $0x2c,%esp
  8001dc:	5b                   	pop    %ebx
  8001dd:	5e                   	pop    %esi
  8001de:	5f                   	pop    %edi
  8001df:	5d                   	pop    %ebp
  8001e0:	c3                   	ret    

008001e1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	57                   	push   %edi
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ef:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800200:	85 c0                	test   %eax,%eax
  800202:	7e 28                	jle    80022c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800204:	89 44 24 10          	mov    %eax,0x10(%esp)
  800208:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80020f:	00 
  800210:	c7 44 24 08 2a 1f 80 	movl   $0x801f2a,0x8(%esp)
  800217:	00 
  800218:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80021f:	00 
  800220:	c7 04 24 47 1f 80 00 	movl   $0x801f47,(%esp)
  800227:	e8 44 0f 00 00       	call   801170 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80022c:	83 c4 2c             	add    $0x2c,%esp
  80022f:	5b                   	pop    %ebx
  800230:	5e                   	pop    %esi
  800231:	5f                   	pop    %edi
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    

00800234 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800242:	b8 06 00 00 00       	mov    $0x6,%eax
  800247:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024a:	8b 55 08             	mov    0x8(%ebp),%edx
  80024d:	89 df                	mov    %ebx,%edi
  80024f:	89 de                	mov    %ebx,%esi
  800251:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800253:	85 c0                	test   %eax,%eax
  800255:	7e 28                	jle    80027f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800257:	89 44 24 10          	mov    %eax,0x10(%esp)
  80025b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800262:	00 
  800263:	c7 44 24 08 2a 1f 80 	movl   $0x801f2a,0x8(%esp)
  80026a:	00 
  80026b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800272:	00 
  800273:	c7 04 24 47 1f 80 00 	movl   $0x801f47,(%esp)
  80027a:	e8 f1 0e 00 00       	call   801170 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80027f:	83 c4 2c             	add    $0x2c,%esp
  800282:	5b                   	pop    %ebx
  800283:	5e                   	pop    %esi
  800284:	5f                   	pop    %edi
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	57                   	push   %edi
  80028b:	56                   	push   %esi
  80028c:	53                   	push   %ebx
  80028d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800290:	bb 00 00 00 00       	mov    $0x0,%ebx
  800295:	b8 08 00 00 00       	mov    $0x8,%eax
  80029a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029d:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a0:	89 df                	mov    %ebx,%edi
  8002a2:	89 de                	mov    %ebx,%esi
  8002a4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a6:	85 c0                	test   %eax,%eax
  8002a8:	7e 28                	jle    8002d2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ae:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 08 2a 1f 80 	movl   $0x801f2a,0x8(%esp)
  8002bd:	00 
  8002be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c5:	00 
  8002c6:	c7 04 24 47 1f 80 00 	movl   $0x801f47,(%esp)
  8002cd:	e8 9e 0e 00 00       	call   801170 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002d2:	83 c4 2c             	add    $0x2c,%esp
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	57                   	push   %edi
  8002de:	56                   	push   %esi
  8002df:	53                   	push   %ebx
  8002e0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e8:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f3:	89 df                	mov    %ebx,%edi
  8002f5:	89 de                	mov    %ebx,%esi
  8002f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f9:	85 c0                	test   %eax,%eax
  8002fb:	7e 28                	jle    800325 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800301:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800308:	00 
  800309:	c7 44 24 08 2a 1f 80 	movl   $0x801f2a,0x8(%esp)
  800310:	00 
  800311:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800318:	00 
  800319:	c7 04 24 47 1f 80 00 	movl   $0x801f47,(%esp)
  800320:	e8 4b 0e 00 00       	call   801170 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800325:	83 c4 2c             	add    $0x2c,%esp
  800328:	5b                   	pop    %ebx
  800329:	5e                   	pop    %esi
  80032a:	5f                   	pop    %edi
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	57                   	push   %edi
  800331:	56                   	push   %esi
  800332:	53                   	push   %ebx
  800333:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800336:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800340:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800343:	8b 55 08             	mov    0x8(%ebp),%edx
  800346:	89 df                	mov    %ebx,%edi
  800348:	89 de                	mov    %ebx,%esi
  80034a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80034c:	85 c0                	test   %eax,%eax
  80034e:	7e 28                	jle    800378 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800350:	89 44 24 10          	mov    %eax,0x10(%esp)
  800354:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80035b:	00 
  80035c:	c7 44 24 08 2a 1f 80 	movl   $0x801f2a,0x8(%esp)
  800363:	00 
  800364:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80036b:	00 
  80036c:	c7 04 24 47 1f 80 00 	movl   $0x801f47,(%esp)
  800373:	e8 f8 0d 00 00       	call   801170 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800378:	83 c4 2c             	add    $0x2c,%esp
  80037b:	5b                   	pop    %ebx
  80037c:	5e                   	pop    %esi
  80037d:	5f                   	pop    %edi
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	57                   	push   %edi
  800384:	56                   	push   %esi
  800385:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800386:	be 00 00 00 00       	mov    $0x0,%esi
  80038b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800390:	8b 7d 14             	mov    0x14(%ebp),%edi
  800393:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800396:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800399:	8b 55 08             	mov    0x8(%ebp),%edx
  80039c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80039e:	5b                   	pop    %ebx
  80039f:	5e                   	pop    %esi
  8003a0:	5f                   	pop    %edi
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	57                   	push   %edi
  8003a7:	56                   	push   %esi
  8003a8:	53                   	push   %ebx
  8003a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b9:	89 cb                	mov    %ecx,%ebx
  8003bb:	89 cf                	mov    %ecx,%edi
  8003bd:	89 ce                	mov    %ecx,%esi
  8003bf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003c1:	85 c0                	test   %eax,%eax
  8003c3:	7e 28                	jle    8003ed <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003d0:	00 
  8003d1:	c7 44 24 08 2a 1f 80 	movl   $0x801f2a,0x8(%esp)
  8003d8:	00 
  8003d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003e0:	00 
  8003e1:	c7 04 24 47 1f 80 00 	movl   $0x801f47,(%esp)
  8003e8:	e8 83 0d 00 00       	call   801170 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003ed:	83 c4 2c             	add    $0x2c,%esp
  8003f0:	5b                   	pop    %ebx
  8003f1:	5e                   	pop    %esi
  8003f2:	5f                   	pop    %edi
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    
  8003f5:	00 00                	add    %al,(%eax)
	...

008003f8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fe:	05 00 00 00 30       	add    $0x30000000,%eax
  800403:	c1 e8 0c             	shr    $0xc,%eax
}
  800406:	5d                   	pop    %ebp
  800407:	c3                   	ret    

00800408 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80040e:	8b 45 08             	mov    0x8(%ebp),%eax
  800411:	89 04 24             	mov    %eax,(%esp)
  800414:	e8 df ff ff ff       	call   8003f8 <fd2num>
  800419:	05 20 00 0d 00       	add    $0xd0020,%eax
  80041e:	c1 e0 0c             	shl    $0xc,%eax
}
  800421:	c9                   	leave  
  800422:	c3                   	ret    

00800423 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	53                   	push   %ebx
  800427:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80042a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80042f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800431:	89 c2                	mov    %eax,%edx
  800433:	c1 ea 16             	shr    $0x16,%edx
  800436:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80043d:	f6 c2 01             	test   $0x1,%dl
  800440:	74 11                	je     800453 <fd_alloc+0x30>
  800442:	89 c2                	mov    %eax,%edx
  800444:	c1 ea 0c             	shr    $0xc,%edx
  800447:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80044e:	f6 c2 01             	test   $0x1,%dl
  800451:	75 09                	jne    80045c <fd_alloc+0x39>
			*fd_store = fd;
  800453:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800455:	b8 00 00 00 00       	mov    $0x0,%eax
  80045a:	eb 17                	jmp    800473 <fd_alloc+0x50>
  80045c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800461:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800466:	75 c7                	jne    80042f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800468:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80046e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800473:	5b                   	pop    %ebx
  800474:	5d                   	pop    %ebp
  800475:	c3                   	ret    

00800476 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80047c:	83 f8 1f             	cmp    $0x1f,%eax
  80047f:	77 36                	ja     8004b7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800481:	05 00 00 0d 00       	add    $0xd0000,%eax
  800486:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800489:	89 c2                	mov    %eax,%edx
  80048b:	c1 ea 16             	shr    $0x16,%edx
  80048e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800495:	f6 c2 01             	test   $0x1,%dl
  800498:	74 24                	je     8004be <fd_lookup+0x48>
  80049a:	89 c2                	mov    %eax,%edx
  80049c:	c1 ea 0c             	shr    $0xc,%edx
  80049f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004a6:	f6 c2 01             	test   $0x1,%dl
  8004a9:	74 1a                	je     8004c5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ae:	89 02                	mov    %eax,(%edx)
	return 0;
  8004b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b5:	eb 13                	jmp    8004ca <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004bc:	eb 0c                	jmp    8004ca <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004c3:	eb 05                	jmp    8004ca <fd_lookup+0x54>
  8004c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004ca:	5d                   	pop    %ebp
  8004cb:	c3                   	ret    

008004cc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	53                   	push   %ebx
  8004d0:	83 ec 14             	sub    $0x14,%esp
  8004d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8004d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004de:	eb 0e                	jmp    8004ee <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8004e0:	39 08                	cmp    %ecx,(%eax)
  8004e2:	75 09                	jne    8004ed <dev_lookup+0x21>
			*dev = devtab[i];
  8004e4:	89 03                	mov    %eax,(%ebx)
			return 0;
  8004e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004eb:	eb 33                	jmp    800520 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004ed:	42                   	inc    %edx
  8004ee:	8b 04 95 d4 1f 80 00 	mov    0x801fd4(,%edx,4),%eax
  8004f5:	85 c0                	test   %eax,%eax
  8004f7:	75 e7                	jne    8004e0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8004fe:	8b 40 48             	mov    0x48(%eax),%eax
  800501:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800505:	89 44 24 04          	mov    %eax,0x4(%esp)
  800509:	c7 04 24 58 1f 80 00 	movl   $0x801f58,(%esp)
  800510:	e8 53 0d 00 00       	call   801268 <cprintf>
	*dev = 0;
  800515:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80051b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800520:	83 c4 14             	add    $0x14,%esp
  800523:	5b                   	pop    %ebx
  800524:	5d                   	pop    %ebp
  800525:	c3                   	ret    

00800526 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	56                   	push   %esi
  80052a:	53                   	push   %ebx
  80052b:	83 ec 30             	sub    $0x30,%esp
  80052e:	8b 75 08             	mov    0x8(%ebp),%esi
  800531:	8a 45 0c             	mov    0xc(%ebp),%al
  800534:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800537:	89 34 24             	mov    %esi,(%esp)
  80053a:	e8 b9 fe ff ff       	call   8003f8 <fd2num>
  80053f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800542:	89 54 24 04          	mov    %edx,0x4(%esp)
  800546:	89 04 24             	mov    %eax,(%esp)
  800549:	e8 28 ff ff ff       	call   800476 <fd_lookup>
  80054e:	89 c3                	mov    %eax,%ebx
  800550:	85 c0                	test   %eax,%eax
  800552:	78 05                	js     800559 <fd_close+0x33>
	    || fd != fd2)
  800554:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800557:	74 0d                	je     800566 <fd_close+0x40>
		return (must_exist ? r : 0);
  800559:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80055d:	75 46                	jne    8005a5 <fd_close+0x7f>
  80055f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800564:	eb 3f                	jmp    8005a5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800566:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056d:	8b 06                	mov    (%esi),%eax
  80056f:	89 04 24             	mov    %eax,(%esp)
  800572:	e8 55 ff ff ff       	call   8004cc <dev_lookup>
  800577:	89 c3                	mov    %eax,%ebx
  800579:	85 c0                	test   %eax,%eax
  80057b:	78 18                	js     800595 <fd_close+0x6f>
		if (dev->dev_close)
  80057d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800580:	8b 40 10             	mov    0x10(%eax),%eax
  800583:	85 c0                	test   %eax,%eax
  800585:	74 09                	je     800590 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800587:	89 34 24             	mov    %esi,(%esp)
  80058a:	ff d0                	call   *%eax
  80058c:	89 c3                	mov    %eax,%ebx
  80058e:	eb 05                	jmp    800595 <fd_close+0x6f>
		else
			r = 0;
  800590:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800595:	89 74 24 04          	mov    %esi,0x4(%esp)
  800599:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005a0:	e8 8f fc ff ff       	call   800234 <sys_page_unmap>
	return r;
}
  8005a5:	89 d8                	mov    %ebx,%eax
  8005a7:	83 c4 30             	add    $0x30,%esp
  8005aa:	5b                   	pop    %ebx
  8005ab:	5e                   	pop    %esi
  8005ac:	5d                   	pop    %ebp
  8005ad:	c3                   	ret    

008005ae <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005ae:	55                   	push   %ebp
  8005af:	89 e5                	mov    %esp,%ebp
  8005b1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005be:	89 04 24             	mov    %eax,(%esp)
  8005c1:	e8 b0 fe ff ff       	call   800476 <fd_lookup>
  8005c6:	85 c0                	test   %eax,%eax
  8005c8:	78 13                	js     8005dd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8005ca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005d1:	00 
  8005d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005d5:	89 04 24             	mov    %eax,(%esp)
  8005d8:	e8 49 ff ff ff       	call   800526 <fd_close>
}
  8005dd:	c9                   	leave  
  8005de:	c3                   	ret    

008005df <close_all>:

void
close_all(void)
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	53                   	push   %ebx
  8005e3:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005eb:	89 1c 24             	mov    %ebx,(%esp)
  8005ee:	e8 bb ff ff ff       	call   8005ae <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005f3:	43                   	inc    %ebx
  8005f4:	83 fb 20             	cmp    $0x20,%ebx
  8005f7:	75 f2                	jne    8005eb <close_all+0xc>
		close(i);
}
  8005f9:	83 c4 14             	add    $0x14,%esp
  8005fc:	5b                   	pop    %ebx
  8005fd:	5d                   	pop    %ebp
  8005fe:	c3                   	ret    

008005ff <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005ff:	55                   	push   %ebp
  800600:	89 e5                	mov    %esp,%ebp
  800602:	57                   	push   %edi
  800603:	56                   	push   %esi
  800604:	53                   	push   %ebx
  800605:	83 ec 4c             	sub    $0x4c,%esp
  800608:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80060b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80060e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800612:	8b 45 08             	mov    0x8(%ebp),%eax
  800615:	89 04 24             	mov    %eax,(%esp)
  800618:	e8 59 fe ff ff       	call   800476 <fd_lookup>
  80061d:	89 c3                	mov    %eax,%ebx
  80061f:	85 c0                	test   %eax,%eax
  800621:	0f 88 e1 00 00 00    	js     800708 <dup+0x109>
		return r;
	close(newfdnum);
  800627:	89 3c 24             	mov    %edi,(%esp)
  80062a:	e8 7f ff ff ff       	call   8005ae <close>

	newfd = INDEX2FD(newfdnum);
  80062f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800635:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800638:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	e8 c5 fd ff ff       	call   800408 <fd2data>
  800643:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800645:	89 34 24             	mov    %esi,(%esp)
  800648:	e8 bb fd ff ff       	call   800408 <fd2data>
  80064d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800650:	89 d8                	mov    %ebx,%eax
  800652:	c1 e8 16             	shr    $0x16,%eax
  800655:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80065c:	a8 01                	test   $0x1,%al
  80065e:	74 46                	je     8006a6 <dup+0xa7>
  800660:	89 d8                	mov    %ebx,%eax
  800662:	c1 e8 0c             	shr    $0xc,%eax
  800665:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80066c:	f6 c2 01             	test   $0x1,%dl
  80066f:	74 35                	je     8006a6 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800671:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800678:	25 07 0e 00 00       	and    $0xe07,%eax
  80067d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800681:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800684:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800688:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80068f:	00 
  800690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800694:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80069b:	e8 41 fb ff ff       	call   8001e1 <sys_page_map>
  8006a0:	89 c3                	mov    %eax,%ebx
  8006a2:	85 c0                	test   %eax,%eax
  8006a4:	78 3b                	js     8006e1 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006a9:	89 c2                	mov    %eax,%edx
  8006ab:	c1 ea 0c             	shr    $0xc,%edx
  8006ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006b5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006bb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006bf:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006ca:	00 
  8006cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006d6:	e8 06 fb ff ff       	call   8001e1 <sys_page_map>
  8006db:	89 c3                	mov    %eax,%ebx
  8006dd:	85 c0                	test   %eax,%eax
  8006df:	79 25                	jns    800706 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006ec:	e8 43 fb ff ff       	call   800234 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006ff:	e8 30 fb ff ff       	call   800234 <sys_page_unmap>
	return r;
  800704:	eb 02                	jmp    800708 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800706:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800708:	89 d8                	mov    %ebx,%eax
  80070a:	83 c4 4c             	add    $0x4c,%esp
  80070d:	5b                   	pop    %ebx
  80070e:	5e                   	pop    %esi
  80070f:	5f                   	pop    %edi
  800710:	5d                   	pop    %ebp
  800711:	c3                   	ret    

00800712 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	53                   	push   %ebx
  800716:	83 ec 24             	sub    $0x24,%esp
  800719:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800723:	89 1c 24             	mov    %ebx,(%esp)
  800726:	e8 4b fd ff ff       	call   800476 <fd_lookup>
  80072b:	85 c0                	test   %eax,%eax
  80072d:	78 6d                	js     80079c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800732:	89 44 24 04          	mov    %eax,0x4(%esp)
  800736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800739:	8b 00                	mov    (%eax),%eax
  80073b:	89 04 24             	mov    %eax,(%esp)
  80073e:	e8 89 fd ff ff       	call   8004cc <dev_lookup>
  800743:	85 c0                	test   %eax,%eax
  800745:	78 55                	js     80079c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800747:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074a:	8b 50 08             	mov    0x8(%eax),%edx
  80074d:	83 e2 03             	and    $0x3,%edx
  800750:	83 fa 01             	cmp    $0x1,%edx
  800753:	75 23                	jne    800778 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800755:	a1 04 40 80 00       	mov    0x804004,%eax
  80075a:	8b 40 48             	mov    0x48(%eax),%eax
  80075d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800761:	89 44 24 04          	mov    %eax,0x4(%esp)
  800765:	c7 04 24 99 1f 80 00 	movl   $0x801f99,(%esp)
  80076c:	e8 f7 0a 00 00       	call   801268 <cprintf>
		return -E_INVAL;
  800771:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800776:	eb 24                	jmp    80079c <read+0x8a>
	}
	if (!dev->dev_read)
  800778:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80077b:	8b 52 08             	mov    0x8(%edx),%edx
  80077e:	85 d2                	test   %edx,%edx
  800780:	74 15                	je     800797 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800782:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800785:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800789:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800790:	89 04 24             	mov    %eax,(%esp)
  800793:	ff d2                	call   *%edx
  800795:	eb 05                	jmp    80079c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800797:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80079c:	83 c4 24             	add    $0x24,%esp
  80079f:	5b                   	pop    %ebx
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	57                   	push   %edi
  8007a6:	56                   	push   %esi
  8007a7:	53                   	push   %ebx
  8007a8:	83 ec 1c             	sub    $0x1c,%esp
  8007ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ae:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007b6:	eb 23                	jmp    8007db <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007b8:	89 f0                	mov    %esi,%eax
  8007ba:	29 d8                	sub    %ebx,%eax
  8007bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c3:	01 d8                	add    %ebx,%eax
  8007c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c9:	89 3c 24             	mov    %edi,(%esp)
  8007cc:	e8 41 ff ff ff       	call   800712 <read>
		if (m < 0)
  8007d1:	85 c0                	test   %eax,%eax
  8007d3:	78 10                	js     8007e5 <readn+0x43>
			return m;
		if (m == 0)
  8007d5:	85 c0                	test   %eax,%eax
  8007d7:	74 0a                	je     8007e3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007d9:	01 c3                	add    %eax,%ebx
  8007db:	39 f3                	cmp    %esi,%ebx
  8007dd:	72 d9                	jb     8007b8 <readn+0x16>
  8007df:	89 d8                	mov    %ebx,%eax
  8007e1:	eb 02                	jmp    8007e5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8007e3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007e5:	83 c4 1c             	add    $0x1c,%esp
  8007e8:	5b                   	pop    %ebx
  8007e9:	5e                   	pop    %esi
  8007ea:	5f                   	pop    %edi
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    

008007ed <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	53                   	push   %ebx
  8007f1:	83 ec 24             	sub    $0x24,%esp
  8007f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fe:	89 1c 24             	mov    %ebx,(%esp)
  800801:	e8 70 fc ff ff       	call   800476 <fd_lookup>
  800806:	85 c0                	test   %eax,%eax
  800808:	78 68                	js     800872 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80080d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800811:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800814:	8b 00                	mov    (%eax),%eax
  800816:	89 04 24             	mov    %eax,(%esp)
  800819:	e8 ae fc ff ff       	call   8004cc <dev_lookup>
  80081e:	85 c0                	test   %eax,%eax
  800820:	78 50                	js     800872 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800822:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800825:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800829:	75 23                	jne    80084e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80082b:	a1 04 40 80 00       	mov    0x804004,%eax
  800830:	8b 40 48             	mov    0x48(%eax),%eax
  800833:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083b:	c7 04 24 b5 1f 80 00 	movl   $0x801fb5,(%esp)
  800842:	e8 21 0a 00 00       	call   801268 <cprintf>
		return -E_INVAL;
  800847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084c:	eb 24                	jmp    800872 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80084e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800851:	8b 52 0c             	mov    0xc(%edx),%edx
  800854:	85 d2                	test   %edx,%edx
  800856:	74 15                	je     80086d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800858:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80085b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80085f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800862:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800866:	89 04 24             	mov    %eax,(%esp)
  800869:	ff d2                	call   *%edx
  80086b:	eb 05                	jmp    800872 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80086d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800872:	83 c4 24             	add    $0x24,%esp
  800875:	5b                   	pop    %ebx
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <seek>:

int
seek(int fdnum, off_t offset)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80087e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800881:	89 44 24 04          	mov    %eax,0x4(%esp)
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	89 04 24             	mov    %eax,(%esp)
  80088b:	e8 e6 fb ff ff       	call   800476 <fd_lookup>
  800890:	85 c0                	test   %eax,%eax
  800892:	78 0e                	js     8008a2 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800894:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800897:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a2:	c9                   	leave  
  8008a3:	c3                   	ret    

008008a4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	53                   	push   %ebx
  8008a8:	83 ec 24             	sub    $0x24,%esp
  8008ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b5:	89 1c 24             	mov    %ebx,(%esp)
  8008b8:	e8 b9 fb ff ff       	call   800476 <fd_lookup>
  8008bd:	85 c0                	test   %eax,%eax
  8008bf:	78 61                	js     800922 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008cb:	8b 00                	mov    (%eax),%eax
  8008cd:	89 04 24             	mov    %eax,(%esp)
  8008d0:	e8 f7 fb ff ff       	call   8004cc <dev_lookup>
  8008d5:	85 c0                	test   %eax,%eax
  8008d7:	78 49                	js     800922 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008e0:	75 23                	jne    800905 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008e2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008e7:	8b 40 48             	mov    0x48(%eax),%eax
  8008ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f2:	c7 04 24 78 1f 80 00 	movl   $0x801f78,(%esp)
  8008f9:	e8 6a 09 00 00       	call   801268 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800903:	eb 1d                	jmp    800922 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800905:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800908:	8b 52 18             	mov    0x18(%edx),%edx
  80090b:	85 d2                	test   %edx,%edx
  80090d:	74 0e                	je     80091d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80090f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800912:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800916:	89 04 24             	mov    %eax,(%esp)
  800919:	ff d2                	call   *%edx
  80091b:	eb 05                	jmp    800922 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80091d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800922:	83 c4 24             	add    $0x24,%esp
  800925:	5b                   	pop    %ebx
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	53                   	push   %ebx
  80092c:	83 ec 24             	sub    $0x24,%esp
  80092f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800932:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800935:	89 44 24 04          	mov    %eax,0x4(%esp)
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	89 04 24             	mov    %eax,(%esp)
  80093f:	e8 32 fb ff ff       	call   800476 <fd_lookup>
  800944:	85 c0                	test   %eax,%eax
  800946:	78 52                	js     80099a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800948:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80094b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800952:	8b 00                	mov    (%eax),%eax
  800954:	89 04 24             	mov    %eax,(%esp)
  800957:	e8 70 fb ff ff       	call   8004cc <dev_lookup>
  80095c:	85 c0                	test   %eax,%eax
  80095e:	78 3a                	js     80099a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800960:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800963:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800967:	74 2c                	je     800995 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800969:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80096c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800973:	00 00 00 
	stat->st_isdir = 0;
  800976:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80097d:	00 00 00 
	stat->st_dev = dev;
  800980:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800986:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80098a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80098d:	89 14 24             	mov    %edx,(%esp)
  800990:	ff 50 14             	call   *0x14(%eax)
  800993:	eb 05                	jmp    80099a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800995:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80099a:	83 c4 24             	add    $0x24,%esp
  80099d:	5b                   	pop    %ebx
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009af:	00 
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	89 04 24             	mov    %eax,(%esp)
  8009b6:	e8 fe 01 00 00       	call   800bb9 <open>
  8009bb:	89 c3                	mov    %eax,%ebx
  8009bd:	85 c0                	test   %eax,%eax
  8009bf:	78 1b                	js     8009dc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c8:	89 1c 24             	mov    %ebx,(%esp)
  8009cb:	e8 58 ff ff ff       	call   800928 <fstat>
  8009d0:	89 c6                	mov    %eax,%esi
	close(fd);
  8009d2:	89 1c 24             	mov    %ebx,(%esp)
  8009d5:	e8 d4 fb ff ff       	call   8005ae <close>
	return r;
  8009da:	89 f3                	mov    %esi,%ebx
}
  8009dc:	89 d8                	mov    %ebx,%eax
  8009de:	83 c4 10             	add    $0x10,%esp
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    
  8009e5:	00 00                	add    %al,(%eax)
	...

008009e8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	83 ec 10             	sub    $0x10,%esp
  8009f0:	89 c3                	mov    %eax,%ebx
  8009f2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8009f4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009fb:	75 11                	jne    800a0e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a04:	e8 20 12 00 00       	call   801c29 <ipc_find_env>
  800a09:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a0e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a15:	00 
  800a16:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a1d:	00 
  800a1e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a22:	a1 00 40 80 00       	mov    0x804000,%eax
  800a27:	89 04 24             	mov    %eax,(%esp)
  800a2a:	e8 90 11 00 00       	call   801bbf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a36:	00 
  800a37:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a42:	e8 11 11 00 00       	call   801b58 <ipc_recv>
}
  800a47:	83 c4 10             	add    $0x10,%esp
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 40 0c             	mov    0xc(%eax),%eax
  800a5a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a62:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a67:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6c:	b8 02 00 00 00       	mov    $0x2,%eax
  800a71:	e8 72 ff ff ff       	call   8009e8 <fsipc>
}
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	8b 40 0c             	mov    0xc(%eax),%eax
  800a84:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a89:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800a93:	e8 50 ff ff ff       	call   8009e8 <fsipc>
}
  800a98:	c9                   	leave  
  800a99:	c3                   	ret    

00800a9a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	53                   	push   %ebx
  800a9e:	83 ec 14             	sub    $0x14,%esp
  800aa1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa7:	8b 40 0c             	mov    0xc(%eax),%eax
  800aaa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800aaf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab4:	b8 05 00 00 00       	mov    $0x5,%eax
  800ab9:	e8 2a ff ff ff       	call   8009e8 <fsipc>
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	78 2b                	js     800aed <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ac2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ac9:	00 
  800aca:	89 1c 24             	mov    %ebx,(%esp)
  800acd:	e8 61 0d 00 00       	call   801833 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ad2:	a1 80 50 80 00       	mov    0x805080,%eax
  800ad7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800add:	a1 84 50 80 00       	mov    0x805084,%eax
  800ae2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aed:	83 c4 14             	add    $0x14,%esp
  800af0:	5b                   	pop    %ebx
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800af9:	c7 44 24 08 e4 1f 80 	movl   $0x801fe4,0x8(%esp)
  800b00:	00 
  800b01:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800b08:	00 
  800b09:	c7 04 24 02 20 80 00 	movl   $0x802002,(%esp)
  800b10:	e8 5b 06 00 00       	call   801170 <_panic>

00800b15 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
  800b1a:	83 ec 10             	sub    $0x10,%esp
  800b1d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b20:	8b 45 08             	mov    0x8(%ebp),%eax
  800b23:	8b 40 0c             	mov    0xc(%eax),%eax
  800b26:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b2b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b31:	ba 00 00 00 00       	mov    $0x0,%edx
  800b36:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3b:	e8 a8 fe ff ff       	call   8009e8 <fsipc>
  800b40:	89 c3                	mov    %eax,%ebx
  800b42:	85 c0                	test   %eax,%eax
  800b44:	78 6a                	js     800bb0 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800b46:	39 c6                	cmp    %eax,%esi
  800b48:	73 24                	jae    800b6e <devfile_read+0x59>
  800b4a:	c7 44 24 0c 0d 20 80 	movl   $0x80200d,0xc(%esp)
  800b51:	00 
  800b52:	c7 44 24 08 14 20 80 	movl   $0x802014,0x8(%esp)
  800b59:	00 
  800b5a:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800b61:	00 
  800b62:	c7 04 24 02 20 80 00 	movl   $0x802002,(%esp)
  800b69:	e8 02 06 00 00       	call   801170 <_panic>
	assert(r <= PGSIZE);
  800b6e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b73:	7e 24                	jle    800b99 <devfile_read+0x84>
  800b75:	c7 44 24 0c 29 20 80 	movl   $0x802029,0xc(%esp)
  800b7c:	00 
  800b7d:	c7 44 24 08 14 20 80 	movl   $0x802014,0x8(%esp)
  800b84:	00 
  800b85:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800b8c:	00 
  800b8d:	c7 04 24 02 20 80 00 	movl   $0x802002,(%esp)
  800b94:	e8 d7 05 00 00       	call   801170 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b99:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b9d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ba4:	00 
  800ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba8:	89 04 24             	mov    %eax,(%esp)
  800bab:	e8 fc 0d 00 00       	call   8019ac <memmove>
	return r;
}
  800bb0:	89 d8                	mov    %ebx,%eax
  800bb2:	83 c4 10             	add    $0x10,%esp
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 20             	sub    $0x20,%esp
  800bc1:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800bc4:	89 34 24             	mov    %esi,(%esp)
  800bc7:	e8 34 0c 00 00       	call   801800 <strlen>
  800bcc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800bd1:	7f 60                	jg     800c33 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bd6:	89 04 24             	mov    %eax,(%esp)
  800bd9:	e8 45 f8 ff ff       	call   800423 <fd_alloc>
  800bde:	89 c3                	mov    %eax,%ebx
  800be0:	85 c0                	test   %eax,%eax
  800be2:	78 54                	js     800c38 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800be4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800be8:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800bef:	e8 3f 0c 00 00       	call   801833 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bfc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bff:	b8 01 00 00 00       	mov    $0x1,%eax
  800c04:	e8 df fd ff ff       	call   8009e8 <fsipc>
  800c09:	89 c3                	mov    %eax,%ebx
  800c0b:	85 c0                	test   %eax,%eax
  800c0d:	79 15                	jns    800c24 <open+0x6b>
		fd_close(fd, 0);
  800c0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c16:	00 
  800c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1a:	89 04 24             	mov    %eax,(%esp)
  800c1d:	e8 04 f9 ff ff       	call   800526 <fd_close>
		return r;
  800c22:	eb 14                	jmp    800c38 <open+0x7f>
	}

	return fd2num(fd);
  800c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c27:	89 04 24             	mov    %eax,(%esp)
  800c2a:	e8 c9 f7 ff ff       	call   8003f8 <fd2num>
  800c2f:	89 c3                	mov    %eax,%ebx
  800c31:	eb 05                	jmp    800c38 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c33:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c38:	89 d8                	mov    %ebx,%eax
  800c3a:	83 c4 20             	add    $0x20,%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c47:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c51:	e8 92 fd ff ff       	call   8009e8 <fsipc>
}
  800c56:	c9                   	leave  
  800c57:	c3                   	ret    

00800c58 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 10             	sub    $0x10,%esp
  800c60:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c63:	8b 45 08             	mov    0x8(%ebp),%eax
  800c66:	89 04 24             	mov    %eax,(%esp)
  800c69:	e8 9a f7 ff ff       	call   800408 <fd2data>
  800c6e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800c70:	c7 44 24 04 35 20 80 	movl   $0x802035,0x4(%esp)
  800c77:	00 
  800c78:	89 34 24             	mov    %esi,(%esp)
  800c7b:	e8 b3 0b 00 00       	call   801833 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c80:	8b 43 04             	mov    0x4(%ebx),%eax
  800c83:	2b 03                	sub    (%ebx),%eax
  800c85:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800c8b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800c92:	00 00 00 
	stat->st_dev = &devpipe;
  800c95:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800c9c:	30 80 00 
	return 0;
}
  800c9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca4:	83 c4 10             	add    $0x10,%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	53                   	push   %ebx
  800caf:	83 ec 14             	sub    $0x14,%esp
  800cb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800cb5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cc0:	e8 6f f5 ff ff       	call   800234 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800cc5:	89 1c 24             	mov    %ebx,(%esp)
  800cc8:	e8 3b f7 ff ff       	call   800408 <fd2data>
  800ccd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cd8:	e8 57 f5 ff ff       	call   800234 <sys_page_unmap>
}
  800cdd:	83 c4 14             	add    $0x14,%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 2c             	sub    $0x2c,%esp
  800cec:	89 c7                	mov    %eax,%edi
  800cee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800cf1:	a1 04 40 80 00       	mov    0x804004,%eax
  800cf6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800cf9:	89 3c 24             	mov    %edi,(%esp)
  800cfc:	e8 6f 0f 00 00       	call   801c70 <pageref>
  800d01:	89 c6                	mov    %eax,%esi
  800d03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d06:	89 04 24             	mov    %eax,(%esp)
  800d09:	e8 62 0f 00 00       	call   801c70 <pageref>
  800d0e:	39 c6                	cmp    %eax,%esi
  800d10:	0f 94 c0             	sete   %al
  800d13:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800d16:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800d1c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800d1f:	39 cb                	cmp    %ecx,%ebx
  800d21:	75 08                	jne    800d2b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800d23:	83 c4 2c             	add    $0x2c,%esp
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800d2b:	83 f8 01             	cmp    $0x1,%eax
  800d2e:	75 c1                	jne    800cf1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800d30:	8b 42 58             	mov    0x58(%edx),%eax
  800d33:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800d3a:	00 
  800d3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d3f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d43:	c7 04 24 3c 20 80 00 	movl   $0x80203c,(%esp)
  800d4a:	e8 19 05 00 00       	call   801268 <cprintf>
  800d4f:	eb a0                	jmp    800cf1 <_pipeisclosed+0xe>

00800d51 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	57                   	push   %edi
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
  800d57:	83 ec 1c             	sub    $0x1c,%esp
  800d5a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800d5d:	89 34 24             	mov    %esi,(%esp)
  800d60:	e8 a3 f6 ff ff       	call   800408 <fd2data>
  800d65:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d67:	bf 00 00 00 00       	mov    $0x0,%edi
  800d6c:	eb 3c                	jmp    800daa <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800d6e:	89 da                	mov    %ebx,%edx
  800d70:	89 f0                	mov    %esi,%eax
  800d72:	e8 6c ff ff ff       	call   800ce3 <_pipeisclosed>
  800d77:	85 c0                	test   %eax,%eax
  800d79:	75 38                	jne    800db3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800d7b:	e8 ee f3 ff ff       	call   80016e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d80:	8b 43 04             	mov    0x4(%ebx),%eax
  800d83:	8b 13                	mov    (%ebx),%edx
  800d85:	83 c2 20             	add    $0x20,%edx
  800d88:	39 d0                	cmp    %edx,%eax
  800d8a:	73 e2                	jae    800d6e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d8f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800d92:	89 c2                	mov    %eax,%edx
  800d94:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800d9a:	79 05                	jns    800da1 <devpipe_write+0x50>
  800d9c:	4a                   	dec    %edx
  800d9d:	83 ca e0             	or     $0xffffffe0,%edx
  800da0:	42                   	inc    %edx
  800da1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800da5:	40                   	inc    %eax
  800da6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800da9:	47                   	inc    %edi
  800daa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800dad:	75 d1                	jne    800d80 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800daf:	89 f8                	mov    %edi,%eax
  800db1:	eb 05                	jmp    800db8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800db3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800db8:	83 c4 1c             	add    $0x1c,%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 1c             	sub    $0x1c,%esp
  800dc9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800dcc:	89 3c 24             	mov    %edi,(%esp)
  800dcf:	e8 34 f6 ff ff       	call   800408 <fd2data>
  800dd4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800dd6:	be 00 00 00 00       	mov    $0x0,%esi
  800ddb:	eb 3a                	jmp    800e17 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ddd:	85 f6                	test   %esi,%esi
  800ddf:	74 04                	je     800de5 <devpipe_read+0x25>
				return i;
  800de1:	89 f0                	mov    %esi,%eax
  800de3:	eb 40                	jmp    800e25 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800de5:	89 da                	mov    %ebx,%edx
  800de7:	89 f8                	mov    %edi,%eax
  800de9:	e8 f5 fe ff ff       	call   800ce3 <_pipeisclosed>
  800dee:	85 c0                	test   %eax,%eax
  800df0:	75 2e                	jne    800e20 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800df2:	e8 77 f3 ff ff       	call   80016e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800df7:	8b 03                	mov    (%ebx),%eax
  800df9:	3b 43 04             	cmp    0x4(%ebx),%eax
  800dfc:	74 df                	je     800ddd <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800dfe:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800e03:	79 05                	jns    800e0a <devpipe_read+0x4a>
  800e05:	48                   	dec    %eax
  800e06:	83 c8 e0             	or     $0xffffffe0,%eax
  800e09:	40                   	inc    %eax
  800e0a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800e0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e11:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800e14:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e16:	46                   	inc    %esi
  800e17:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e1a:	75 db                	jne    800df7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800e1c:	89 f0                	mov    %esi,%eax
  800e1e:	eb 05                	jmp    800e25 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e20:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800e25:	83 c4 1c             	add    $0x1c,%esp
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	57                   	push   %edi
  800e31:	56                   	push   %esi
  800e32:	53                   	push   %ebx
  800e33:	83 ec 3c             	sub    $0x3c,%esp
  800e36:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800e39:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e3c:	89 04 24             	mov    %eax,(%esp)
  800e3f:	e8 df f5 ff ff       	call   800423 <fd_alloc>
  800e44:	89 c3                	mov    %eax,%ebx
  800e46:	85 c0                	test   %eax,%eax
  800e48:	0f 88 45 01 00 00    	js     800f93 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e4e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e55:	00 
  800e56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e59:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e64:	e8 24 f3 ff ff       	call   80018d <sys_page_alloc>
  800e69:	89 c3                	mov    %eax,%ebx
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	0f 88 20 01 00 00    	js     800f93 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800e73:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800e76:	89 04 24             	mov    %eax,(%esp)
  800e79:	e8 a5 f5 ff ff       	call   800423 <fd_alloc>
  800e7e:	89 c3                	mov    %eax,%ebx
  800e80:	85 c0                	test   %eax,%eax
  800e82:	0f 88 f8 00 00 00    	js     800f80 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e88:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e8f:	00 
  800e90:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e93:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e9e:	e8 ea f2 ff ff       	call   80018d <sys_page_alloc>
  800ea3:	89 c3                	mov    %eax,%ebx
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	0f 88 d3 00 00 00    	js     800f80 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800ead:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800eb0:	89 04 24             	mov    %eax,(%esp)
  800eb3:	e8 50 f5 ff ff       	call   800408 <fd2data>
  800eb8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800eba:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ec1:	00 
  800ec2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ec6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ecd:	e8 bb f2 ff ff       	call   80018d <sys_page_alloc>
  800ed2:	89 c3                	mov    %eax,%ebx
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	0f 88 91 00 00 00    	js     800f6d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800edc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800edf:	89 04 24             	mov    %eax,(%esp)
  800ee2:	e8 21 f5 ff ff       	call   800408 <fd2data>
  800ee7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800eee:	00 
  800eef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ef3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800efa:	00 
  800efb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f06:	e8 d6 f2 ff ff       	call   8001e1 <sys_page_map>
  800f0b:	89 c3                	mov    %eax,%ebx
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	78 4c                	js     800f5d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800f11:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f1a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800f1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f1f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800f26:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f2f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800f31:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f34:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800f3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f3e:	89 04 24             	mov    %eax,(%esp)
  800f41:	e8 b2 f4 ff ff       	call   8003f8 <fd2num>
  800f46:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800f48:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f4b:	89 04 24             	mov    %eax,(%esp)
  800f4e:	e8 a5 f4 ff ff       	call   8003f8 <fd2num>
  800f53:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800f56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5b:	eb 36                	jmp    800f93 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  800f5d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f68:	e8 c7 f2 ff ff       	call   800234 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  800f6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f70:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f7b:	e8 b4 f2 ff ff       	call   800234 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  800f80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f8e:	e8 a1 f2 ff ff       	call   800234 <sys_page_unmap>
    err:
	return r;
}
  800f93:	89 d8                	mov    %ebx,%eax
  800f95:	83 c4 3c             	add    $0x3c,%esp
  800f98:	5b                   	pop    %ebx
  800f99:	5e                   	pop    %esi
  800f9a:	5f                   	pop    %edi
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    

00800f9d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800faa:	8b 45 08             	mov    0x8(%ebp),%eax
  800fad:	89 04 24             	mov    %eax,(%esp)
  800fb0:	e8 c1 f4 ff ff       	call   800476 <fd_lookup>
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	78 15                	js     800fce <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fbc:	89 04 24             	mov    %eax,(%esp)
  800fbf:	e8 44 f4 ff ff       	call   800408 <fd2data>
	return _pipeisclosed(fd, p);
  800fc4:	89 c2                	mov    %eax,%edx
  800fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc9:	e8 15 fd ff ff       	call   800ce3 <_pipeisclosed>
}
  800fce:	c9                   	leave  
  800fcf:	c3                   	ret    

00800fd0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800fd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800fe0:	c7 44 24 04 54 20 80 	movl   $0x802054,0x4(%esp)
  800fe7:	00 
  800fe8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800feb:	89 04 24             	mov    %eax,(%esp)
  800fee:	e8 40 08 00 00       	call   801833 <strcpy>
	return 0;
}
  800ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff8:	c9                   	leave  
  800ff9:	c3                   	ret    

00800ffa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	57                   	push   %edi
  800ffe:	56                   	push   %esi
  800fff:	53                   	push   %ebx
  801000:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801006:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80100b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801011:	eb 30                	jmp    801043 <devcons_write+0x49>
		m = n - tot;
  801013:	8b 75 10             	mov    0x10(%ebp),%esi
  801016:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801018:	83 fe 7f             	cmp    $0x7f,%esi
  80101b:	76 05                	jbe    801022 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80101d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801022:	89 74 24 08          	mov    %esi,0x8(%esp)
  801026:	03 45 0c             	add    0xc(%ebp),%eax
  801029:	89 44 24 04          	mov    %eax,0x4(%esp)
  80102d:	89 3c 24             	mov    %edi,(%esp)
  801030:	e8 77 09 00 00       	call   8019ac <memmove>
		sys_cputs(buf, m);
  801035:	89 74 24 04          	mov    %esi,0x4(%esp)
  801039:	89 3c 24             	mov    %edi,(%esp)
  80103c:	e8 7f f0 ff ff       	call   8000c0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801041:	01 f3                	add    %esi,%ebx
  801043:	89 d8                	mov    %ebx,%eax
  801045:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801048:	72 c9                	jb     801013 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80104a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801050:	5b                   	pop    %ebx
  801051:	5e                   	pop    %esi
  801052:	5f                   	pop    %edi
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    

00801055 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80105b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80105f:	75 07                	jne    801068 <devcons_read+0x13>
  801061:	eb 25                	jmp    801088 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801063:	e8 06 f1 ff ff       	call   80016e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801068:	e8 71 f0 ff ff       	call   8000de <sys_cgetc>
  80106d:	85 c0                	test   %eax,%eax
  80106f:	74 f2                	je     801063 <devcons_read+0xe>
  801071:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801073:	85 c0                	test   %eax,%eax
  801075:	78 1d                	js     801094 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801077:	83 f8 04             	cmp    $0x4,%eax
  80107a:	74 13                	je     80108f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80107c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107f:	88 10                	mov    %dl,(%eax)
	return 1;
  801081:	b8 01 00 00 00       	mov    $0x1,%eax
  801086:	eb 0c                	jmp    801094 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801088:	b8 00 00 00 00       	mov    $0x0,%eax
  80108d:	eb 05                	jmp    801094 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80108f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801094:	c9                   	leave  
  801095:	c3                   	ret    

00801096 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80109c:	8b 45 08             	mov    0x8(%ebp),%eax
  80109f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8010a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010a9:	00 
  8010aa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010ad:	89 04 24             	mov    %eax,(%esp)
  8010b0:	e8 0b f0 ff ff       	call   8000c0 <sys_cputs>
}
  8010b5:	c9                   	leave  
  8010b6:	c3                   	ret    

008010b7 <getchar>:

int
getchar(void)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8010bd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010c4:	00 
  8010c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d3:	e8 3a f6 ff ff       	call   800712 <read>
	if (r < 0)
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	78 0f                	js     8010eb <getchar+0x34>
		return r;
	if (r < 1)
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	7e 06                	jle    8010e6 <getchar+0x2f>
		return -E_EOF;
	return c;
  8010e0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8010e4:	eb 05                	jmp    8010eb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8010e6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8010eb:	c9                   	leave  
  8010ec:	c3                   	ret    

008010ed <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fd:	89 04 24             	mov    %eax,(%esp)
  801100:	e8 71 f3 ff ff       	call   800476 <fd_lookup>
  801105:	85 c0                	test   %eax,%eax
  801107:	78 11                	js     80111a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801109:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801112:	39 10                	cmp    %edx,(%eax)
  801114:	0f 94 c0             	sete   %al
  801117:	0f b6 c0             	movzbl %al,%eax
}
  80111a:	c9                   	leave  
  80111b:	c3                   	ret    

0080111c <opencons>:

int
opencons(void)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801122:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801125:	89 04 24             	mov    %eax,(%esp)
  801128:	e8 f6 f2 ff ff       	call   800423 <fd_alloc>
  80112d:	85 c0                	test   %eax,%eax
  80112f:	78 3c                	js     80116d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801131:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801138:	00 
  801139:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801140:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801147:	e8 41 f0 ff ff       	call   80018d <sys_page_alloc>
  80114c:	85 c0                	test   %eax,%eax
  80114e:	78 1d                	js     80116d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801150:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801156:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801159:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80115b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801165:	89 04 24             	mov    %eax,(%esp)
  801168:	e8 8b f2 ff ff       	call   8003f8 <fd2num>
}
  80116d:	c9                   	leave  
  80116e:	c3                   	ret    
	...

00801170 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	56                   	push   %esi
  801174:	53                   	push   %ebx
  801175:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801178:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80117b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801181:	e8 c9 ef ff ff       	call   80014f <sys_getenvid>
  801186:	8b 55 0c             	mov    0xc(%ebp),%edx
  801189:	89 54 24 10          	mov    %edx,0x10(%esp)
  80118d:	8b 55 08             	mov    0x8(%ebp),%edx
  801190:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801194:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119c:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  8011a3:	e8 c0 00 00 00       	call   801268 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8011af:	89 04 24             	mov    %eax,(%esp)
  8011b2:	e8 50 00 00 00       	call   801207 <vcprintf>
	cprintf("\n");
  8011b7:	c7 04 24 4d 20 80 00 	movl   $0x80204d,(%esp)
  8011be:	e8 a5 00 00 00       	call   801268 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011c3:	cc                   	int3   
  8011c4:	eb fd                	jmp    8011c3 <_panic+0x53>
	...

008011c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	53                   	push   %ebx
  8011cc:	83 ec 14             	sub    $0x14,%esp
  8011cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8011d2:	8b 03                	mov    (%ebx),%eax
  8011d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8011db:	40                   	inc    %eax
  8011dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8011de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8011e3:	75 19                	jne    8011fe <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8011e5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8011ec:	00 
  8011ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8011f0:	89 04 24             	mov    %eax,(%esp)
  8011f3:	e8 c8 ee ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  8011f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8011fe:	ff 43 04             	incl   0x4(%ebx)
}
  801201:	83 c4 14             	add    $0x14,%esp
  801204:	5b                   	pop    %ebx
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801210:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801217:	00 00 00 
	b.cnt = 0;
  80121a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801221:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801224:	8b 45 0c             	mov    0xc(%ebp),%eax
  801227:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80122b:	8b 45 08             	mov    0x8(%ebp),%eax
  80122e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801232:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123c:	c7 04 24 c8 11 80 00 	movl   $0x8011c8,(%esp)
  801243:	e8 82 01 00 00       	call   8013ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801248:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80124e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801252:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801258:	89 04 24             	mov    %eax,(%esp)
  80125b:	e8 60 ee ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  801260:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801266:	c9                   	leave  
  801267:	c3                   	ret    

00801268 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80126e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801271:	89 44 24 04          	mov    %eax,0x4(%esp)
  801275:	8b 45 08             	mov    0x8(%ebp),%eax
  801278:	89 04 24             	mov    %eax,(%esp)
  80127b:	e8 87 ff ff ff       	call   801207 <vcprintf>
	va_end(ap);

	return cnt;
}
  801280:	c9                   	leave  
  801281:	c3                   	ret    
	...

00801284 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	57                   	push   %edi
  801288:	56                   	push   %esi
  801289:	53                   	push   %ebx
  80128a:	83 ec 3c             	sub    $0x3c,%esp
  80128d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801290:	89 d7                	mov    %edx,%edi
  801292:	8b 45 08             	mov    0x8(%ebp),%eax
  801295:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801298:	8b 45 0c             	mov    0xc(%ebp),%eax
  80129b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80129e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8012a1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	75 08                	jne    8012b0 <printnum+0x2c>
  8012a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8012ae:	77 57                	ja     801307 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8012b0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012b4:	4b                   	dec    %ebx
  8012b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8012bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8012c4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8012c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012cf:	00 
  8012d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012d3:	89 04 24             	mov    %eax,(%esp)
  8012d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012dd:	e8 d2 09 00 00       	call   801cb4 <__udivdi3>
  8012e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012e6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012ea:	89 04 24             	mov    %eax,(%esp)
  8012ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012f1:	89 fa                	mov    %edi,%edx
  8012f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f6:	e8 89 ff ff ff       	call   801284 <printnum>
  8012fb:	eb 0f                	jmp    80130c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8012fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801301:	89 34 24             	mov    %esi,(%esp)
  801304:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801307:	4b                   	dec    %ebx
  801308:	85 db                	test   %ebx,%ebx
  80130a:	7f f1                	jg     8012fd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80130c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801310:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801314:	8b 45 10             	mov    0x10(%ebp),%eax
  801317:	89 44 24 08          	mov    %eax,0x8(%esp)
  80131b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801322:	00 
  801323:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801326:	89 04 24             	mov    %eax,(%esp)
  801329:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80132c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801330:	e8 9f 0a 00 00       	call   801dd4 <__umoddi3>
  801335:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801339:	0f be 80 83 20 80 00 	movsbl 0x802083(%eax),%eax
  801340:	89 04 24             	mov    %eax,(%esp)
  801343:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801346:	83 c4 3c             	add    $0x3c,%esp
  801349:	5b                   	pop    %ebx
  80134a:	5e                   	pop    %esi
  80134b:	5f                   	pop    %edi
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    

0080134e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801351:	83 fa 01             	cmp    $0x1,%edx
  801354:	7e 0e                	jle    801364 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801356:	8b 10                	mov    (%eax),%edx
  801358:	8d 4a 08             	lea    0x8(%edx),%ecx
  80135b:	89 08                	mov    %ecx,(%eax)
  80135d:	8b 02                	mov    (%edx),%eax
  80135f:	8b 52 04             	mov    0x4(%edx),%edx
  801362:	eb 22                	jmp    801386 <getuint+0x38>
	else if (lflag)
  801364:	85 d2                	test   %edx,%edx
  801366:	74 10                	je     801378 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801368:	8b 10                	mov    (%eax),%edx
  80136a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80136d:	89 08                	mov    %ecx,(%eax)
  80136f:	8b 02                	mov    (%edx),%eax
  801371:	ba 00 00 00 00       	mov    $0x0,%edx
  801376:	eb 0e                	jmp    801386 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801378:	8b 10                	mov    (%eax),%edx
  80137a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80137d:	89 08                	mov    %ecx,(%eax)
  80137f:	8b 02                	mov    (%edx),%eax
  801381:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    

00801388 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80138e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801391:	8b 10                	mov    (%eax),%edx
  801393:	3b 50 04             	cmp    0x4(%eax),%edx
  801396:	73 08                	jae    8013a0 <sprintputch+0x18>
		*b->buf++ = ch;
  801398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80139b:	88 0a                	mov    %cl,(%edx)
  80139d:	42                   	inc    %edx
  80139e:	89 10                	mov    %edx,(%eax)
}
  8013a0:	5d                   	pop    %ebp
  8013a1:	c3                   	ret    

008013a2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8013a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8013ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013af:	8b 45 10             	mov    0x10(%ebp),%eax
  8013b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c0:	89 04 24             	mov    %eax,(%esp)
  8013c3:	e8 02 00 00 00       	call   8013ca <vprintfmt>
	va_end(ap);
}
  8013c8:	c9                   	leave  
  8013c9:	c3                   	ret    

008013ca <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	57                   	push   %edi
  8013ce:	56                   	push   %esi
  8013cf:	53                   	push   %ebx
  8013d0:	83 ec 4c             	sub    $0x4c,%esp
  8013d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013d6:	8b 75 10             	mov    0x10(%ebp),%esi
  8013d9:	eb 12                	jmp    8013ed <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	0f 84 8b 03 00 00    	je     80176e <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8013e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013e7:	89 04 24             	mov    %eax,(%esp)
  8013ea:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8013ed:	0f b6 06             	movzbl (%esi),%eax
  8013f0:	46                   	inc    %esi
  8013f1:	83 f8 25             	cmp    $0x25,%eax
  8013f4:	75 e5                	jne    8013db <vprintfmt+0x11>
  8013f6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8013fa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801401:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801406:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80140d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801412:	eb 26                	jmp    80143a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801414:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801417:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80141b:	eb 1d                	jmp    80143a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80141d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801420:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801424:	eb 14                	jmp    80143a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801426:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801429:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801430:	eb 08                	jmp    80143a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801432:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801435:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80143a:	0f b6 06             	movzbl (%esi),%eax
  80143d:	8d 56 01             	lea    0x1(%esi),%edx
  801440:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801443:	8a 16                	mov    (%esi),%dl
  801445:	83 ea 23             	sub    $0x23,%edx
  801448:	80 fa 55             	cmp    $0x55,%dl
  80144b:	0f 87 01 03 00 00    	ja     801752 <vprintfmt+0x388>
  801451:	0f b6 d2             	movzbl %dl,%edx
  801454:	ff 24 95 c0 21 80 00 	jmp    *0x8021c0(,%edx,4)
  80145b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80145e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801463:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801466:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80146a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80146d:	8d 50 d0             	lea    -0x30(%eax),%edx
  801470:	83 fa 09             	cmp    $0x9,%edx
  801473:	77 2a                	ja     80149f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801475:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801476:	eb eb                	jmp    801463 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801478:	8b 45 14             	mov    0x14(%ebp),%eax
  80147b:	8d 50 04             	lea    0x4(%eax),%edx
  80147e:	89 55 14             	mov    %edx,0x14(%ebp)
  801481:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801483:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801486:	eb 17                	jmp    80149f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801488:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80148c:	78 98                	js     801426 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80148e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801491:	eb a7                	jmp    80143a <vprintfmt+0x70>
  801493:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801496:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80149d:	eb 9b                	jmp    80143a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80149f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8014a3:	79 95                	jns    80143a <vprintfmt+0x70>
  8014a5:	eb 8b                	jmp    801432 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8014a7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8014ab:	eb 8d                	jmp    80143a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8014ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b0:	8d 50 04             	lea    0x4(%eax),%edx
  8014b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8014b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ba:	8b 00                	mov    (%eax),%eax
  8014bc:	89 04 24             	mov    %eax,(%esp)
  8014bf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8014c5:	e9 23 ff ff ff       	jmp    8013ed <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8014ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8014cd:	8d 50 04             	lea    0x4(%eax),%edx
  8014d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d3:	8b 00                	mov    (%eax),%eax
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	79 02                	jns    8014db <vprintfmt+0x111>
  8014d9:	f7 d8                	neg    %eax
  8014db:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8014dd:	83 f8 0f             	cmp    $0xf,%eax
  8014e0:	7f 0b                	jg     8014ed <vprintfmt+0x123>
  8014e2:	8b 04 85 20 23 80 00 	mov    0x802320(,%eax,4),%eax
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	75 23                	jne    801510 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8014ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014f1:	c7 44 24 08 9b 20 80 	movl   $0x80209b,0x8(%esp)
  8014f8:	00 
  8014f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801500:	89 04 24             	mov    %eax,(%esp)
  801503:	e8 9a fe ff ff       	call   8013a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801508:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80150b:	e9 dd fe ff ff       	jmp    8013ed <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801510:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801514:	c7 44 24 08 26 20 80 	movl   $0x802026,0x8(%esp)
  80151b:	00 
  80151c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801520:	8b 55 08             	mov    0x8(%ebp),%edx
  801523:	89 14 24             	mov    %edx,(%esp)
  801526:	e8 77 fe ff ff       	call   8013a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80152b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80152e:	e9 ba fe ff ff       	jmp    8013ed <vprintfmt+0x23>
  801533:	89 f9                	mov    %edi,%ecx
  801535:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801538:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80153b:	8b 45 14             	mov    0x14(%ebp),%eax
  80153e:	8d 50 04             	lea    0x4(%eax),%edx
  801541:	89 55 14             	mov    %edx,0x14(%ebp)
  801544:	8b 30                	mov    (%eax),%esi
  801546:	85 f6                	test   %esi,%esi
  801548:	75 05                	jne    80154f <vprintfmt+0x185>
				p = "(null)";
  80154a:	be 94 20 80 00       	mov    $0x802094,%esi
			if (width > 0 && padc != '-')
  80154f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801553:	0f 8e 84 00 00 00    	jle    8015dd <vprintfmt+0x213>
  801559:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80155d:	74 7e                	je     8015dd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80155f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801563:	89 34 24             	mov    %esi,(%esp)
  801566:	e8 ab 02 00 00       	call   801816 <strnlen>
  80156b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80156e:	29 c2                	sub    %eax,%edx
  801570:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801573:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801577:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80157a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80157d:	89 de                	mov    %ebx,%esi
  80157f:	89 d3                	mov    %edx,%ebx
  801581:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801583:	eb 0b                	jmp    801590 <vprintfmt+0x1c6>
					putch(padc, putdat);
  801585:	89 74 24 04          	mov    %esi,0x4(%esp)
  801589:	89 3c 24             	mov    %edi,(%esp)
  80158c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80158f:	4b                   	dec    %ebx
  801590:	85 db                	test   %ebx,%ebx
  801592:	7f f1                	jg     801585 <vprintfmt+0x1bb>
  801594:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801597:	89 f3                	mov    %esi,%ebx
  801599:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80159c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	79 05                	jns    8015a8 <vprintfmt+0x1de>
  8015a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015ab:	29 c2                	sub    %eax,%edx
  8015ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8015b0:	eb 2b                	jmp    8015dd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8015b2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8015b6:	74 18                	je     8015d0 <vprintfmt+0x206>
  8015b8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8015bb:	83 fa 5e             	cmp    $0x5e,%edx
  8015be:	76 10                	jbe    8015d0 <vprintfmt+0x206>
					putch('?', putdat);
  8015c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015c4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8015cb:	ff 55 08             	call   *0x8(%ebp)
  8015ce:	eb 0a                	jmp    8015da <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8015d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015d4:	89 04 24             	mov    %eax,(%esp)
  8015d7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015da:	ff 4d e4             	decl   -0x1c(%ebp)
  8015dd:	0f be 06             	movsbl (%esi),%eax
  8015e0:	46                   	inc    %esi
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	74 21                	je     801606 <vprintfmt+0x23c>
  8015e5:	85 ff                	test   %edi,%edi
  8015e7:	78 c9                	js     8015b2 <vprintfmt+0x1e8>
  8015e9:	4f                   	dec    %edi
  8015ea:	79 c6                	jns    8015b2 <vprintfmt+0x1e8>
  8015ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ef:	89 de                	mov    %ebx,%esi
  8015f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8015f4:	eb 18                	jmp    80160e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8015f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015fa:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801601:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801603:	4b                   	dec    %ebx
  801604:	eb 08                	jmp    80160e <vprintfmt+0x244>
  801606:	8b 7d 08             	mov    0x8(%ebp),%edi
  801609:	89 de                	mov    %ebx,%esi
  80160b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80160e:	85 db                	test   %ebx,%ebx
  801610:	7f e4                	jg     8015f6 <vprintfmt+0x22c>
  801612:	89 7d 08             	mov    %edi,0x8(%ebp)
  801615:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801617:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80161a:	e9 ce fd ff ff       	jmp    8013ed <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80161f:	83 f9 01             	cmp    $0x1,%ecx
  801622:	7e 10                	jle    801634 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801624:	8b 45 14             	mov    0x14(%ebp),%eax
  801627:	8d 50 08             	lea    0x8(%eax),%edx
  80162a:	89 55 14             	mov    %edx,0x14(%ebp)
  80162d:	8b 30                	mov    (%eax),%esi
  80162f:	8b 78 04             	mov    0x4(%eax),%edi
  801632:	eb 26                	jmp    80165a <vprintfmt+0x290>
	else if (lflag)
  801634:	85 c9                	test   %ecx,%ecx
  801636:	74 12                	je     80164a <vprintfmt+0x280>
		return va_arg(*ap, long);
  801638:	8b 45 14             	mov    0x14(%ebp),%eax
  80163b:	8d 50 04             	lea    0x4(%eax),%edx
  80163e:	89 55 14             	mov    %edx,0x14(%ebp)
  801641:	8b 30                	mov    (%eax),%esi
  801643:	89 f7                	mov    %esi,%edi
  801645:	c1 ff 1f             	sar    $0x1f,%edi
  801648:	eb 10                	jmp    80165a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80164a:	8b 45 14             	mov    0x14(%ebp),%eax
  80164d:	8d 50 04             	lea    0x4(%eax),%edx
  801650:	89 55 14             	mov    %edx,0x14(%ebp)
  801653:	8b 30                	mov    (%eax),%esi
  801655:	89 f7                	mov    %esi,%edi
  801657:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80165a:	85 ff                	test   %edi,%edi
  80165c:	78 0a                	js     801668 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80165e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801663:	e9 ac 00 00 00       	jmp    801714 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801668:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80166c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801673:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801676:	f7 de                	neg    %esi
  801678:	83 d7 00             	adc    $0x0,%edi
  80167b:	f7 df                	neg    %edi
			}
			base = 10;
  80167d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801682:	e9 8d 00 00 00       	jmp    801714 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801687:	89 ca                	mov    %ecx,%edx
  801689:	8d 45 14             	lea    0x14(%ebp),%eax
  80168c:	e8 bd fc ff ff       	call   80134e <getuint>
  801691:	89 c6                	mov    %eax,%esi
  801693:	89 d7                	mov    %edx,%edi
			base = 10;
  801695:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80169a:	eb 78                	jmp    801714 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80169c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016a0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8016a7:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8016aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016ae:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8016b5:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8016b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016bc:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8016c3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8016c9:	e9 1f fd ff ff       	jmp    8013ed <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8016ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8016d9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8016dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016e0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8016e7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8016ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ed:	8d 50 04             	lea    0x4(%eax),%edx
  8016f0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8016f3:	8b 30                	mov    (%eax),%esi
  8016f5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8016fa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8016ff:	eb 13                	jmp    801714 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801701:	89 ca                	mov    %ecx,%edx
  801703:	8d 45 14             	lea    0x14(%ebp),%eax
  801706:	e8 43 fc ff ff       	call   80134e <getuint>
  80170b:	89 c6                	mov    %eax,%esi
  80170d:	89 d7                	mov    %edx,%edi
			base = 16;
  80170f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801714:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801718:	89 54 24 10          	mov    %edx,0x10(%esp)
  80171c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80171f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801723:	89 44 24 08          	mov    %eax,0x8(%esp)
  801727:	89 34 24             	mov    %esi,(%esp)
  80172a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80172e:	89 da                	mov    %ebx,%edx
  801730:	8b 45 08             	mov    0x8(%ebp),%eax
  801733:	e8 4c fb ff ff       	call   801284 <printnum>
			break;
  801738:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80173b:	e9 ad fc ff ff       	jmp    8013ed <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801740:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801744:	89 04 24             	mov    %eax,(%esp)
  801747:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80174d:	e9 9b fc ff ff       	jmp    8013ed <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801752:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801756:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80175d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801760:	eb 01                	jmp    801763 <vprintfmt+0x399>
  801762:	4e                   	dec    %esi
  801763:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801767:	75 f9                	jne    801762 <vprintfmt+0x398>
  801769:	e9 7f fc ff ff       	jmp    8013ed <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80176e:	83 c4 4c             	add    $0x4c,%esp
  801771:	5b                   	pop    %ebx
  801772:	5e                   	pop    %esi
  801773:	5f                   	pop    %edi
  801774:	5d                   	pop    %ebp
  801775:	c3                   	ret    

00801776 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	83 ec 28             	sub    $0x28,%esp
  80177c:	8b 45 08             	mov    0x8(%ebp),%eax
  80177f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801782:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801785:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801789:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80178c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801793:	85 c0                	test   %eax,%eax
  801795:	74 30                	je     8017c7 <vsnprintf+0x51>
  801797:	85 d2                	test   %edx,%edx
  801799:	7e 33                	jle    8017ce <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80179b:	8b 45 14             	mov    0x14(%ebp),%eax
  80179e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8017ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b0:	c7 04 24 88 13 80 00 	movl   $0x801388,(%esp)
  8017b7:	e8 0e fc ff ff       	call   8013ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8017bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8017bf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8017c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c5:	eb 0c                	jmp    8017d3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8017c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017cc:	eb 05                	jmp    8017d3 <vsnprintf+0x5d>
  8017ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8017db:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8017de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8017e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f3:	89 04 24             	mov    %eax,(%esp)
  8017f6:	e8 7b ff ff ff       	call   801776 <vsnprintf>
	va_end(ap);

	return rc;
}
  8017fb:	c9                   	leave  
  8017fc:	c3                   	ret    
  8017fd:	00 00                	add    %al,(%eax)
	...

00801800 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801806:	b8 00 00 00 00       	mov    $0x0,%eax
  80180b:	eb 01                	jmp    80180e <strlen+0xe>
		n++;
  80180d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80180e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801812:	75 f9                	jne    80180d <strlen+0xd>
		n++;
	return n;
}
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    

00801816 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80181c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80181f:	b8 00 00 00 00       	mov    $0x0,%eax
  801824:	eb 01                	jmp    801827 <strnlen+0x11>
		n++;
  801826:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801827:	39 d0                	cmp    %edx,%eax
  801829:	74 06                	je     801831 <strnlen+0x1b>
  80182b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80182f:	75 f5                	jne    801826 <strnlen+0x10>
		n++;
	return n;
}
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    

00801833 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	53                   	push   %ebx
  801837:	8b 45 08             	mov    0x8(%ebp),%eax
  80183a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80183d:	ba 00 00 00 00       	mov    $0x0,%edx
  801842:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801845:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801848:	42                   	inc    %edx
  801849:	84 c9                	test   %cl,%cl
  80184b:	75 f5                	jne    801842 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80184d:	5b                   	pop    %ebx
  80184e:	5d                   	pop    %ebp
  80184f:	c3                   	ret    

00801850 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	53                   	push   %ebx
  801854:	83 ec 08             	sub    $0x8,%esp
  801857:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80185a:	89 1c 24             	mov    %ebx,(%esp)
  80185d:	e8 9e ff ff ff       	call   801800 <strlen>
	strcpy(dst + len, src);
  801862:	8b 55 0c             	mov    0xc(%ebp),%edx
  801865:	89 54 24 04          	mov    %edx,0x4(%esp)
  801869:	01 d8                	add    %ebx,%eax
  80186b:	89 04 24             	mov    %eax,(%esp)
  80186e:	e8 c0 ff ff ff       	call   801833 <strcpy>
	return dst;
}
  801873:	89 d8                	mov    %ebx,%eax
  801875:	83 c4 08             	add    $0x8,%esp
  801878:	5b                   	pop    %ebx
  801879:	5d                   	pop    %ebp
  80187a:	c3                   	ret    

0080187b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	56                   	push   %esi
  80187f:	53                   	push   %ebx
  801880:	8b 45 08             	mov    0x8(%ebp),%eax
  801883:	8b 55 0c             	mov    0xc(%ebp),%edx
  801886:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801889:	b9 00 00 00 00       	mov    $0x0,%ecx
  80188e:	eb 0c                	jmp    80189c <strncpy+0x21>
		*dst++ = *src;
  801890:	8a 1a                	mov    (%edx),%bl
  801892:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801895:	80 3a 01             	cmpb   $0x1,(%edx)
  801898:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80189b:	41                   	inc    %ecx
  80189c:	39 f1                	cmp    %esi,%ecx
  80189e:	75 f0                	jne    801890 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8018a0:	5b                   	pop    %ebx
  8018a1:	5e                   	pop    %esi
  8018a2:	5d                   	pop    %ebp
  8018a3:	c3                   	ret    

008018a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	56                   	push   %esi
  8018a8:	53                   	push   %ebx
  8018a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8018ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018af:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8018b2:	85 d2                	test   %edx,%edx
  8018b4:	75 0a                	jne    8018c0 <strlcpy+0x1c>
  8018b6:	89 f0                	mov    %esi,%eax
  8018b8:	eb 1a                	jmp    8018d4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8018ba:	88 18                	mov    %bl,(%eax)
  8018bc:	40                   	inc    %eax
  8018bd:	41                   	inc    %ecx
  8018be:	eb 02                	jmp    8018c2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8018c0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8018c2:	4a                   	dec    %edx
  8018c3:	74 0a                	je     8018cf <strlcpy+0x2b>
  8018c5:	8a 19                	mov    (%ecx),%bl
  8018c7:	84 db                	test   %bl,%bl
  8018c9:	75 ef                	jne    8018ba <strlcpy+0x16>
  8018cb:	89 c2                	mov    %eax,%edx
  8018cd:	eb 02                	jmp    8018d1 <strlcpy+0x2d>
  8018cf:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8018d1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8018d4:	29 f0                	sub    %esi,%eax
}
  8018d6:	5b                   	pop    %ebx
  8018d7:	5e                   	pop    %esi
  8018d8:	5d                   	pop    %ebp
  8018d9:	c3                   	ret    

008018da <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8018e3:	eb 02                	jmp    8018e7 <strcmp+0xd>
		p++, q++;
  8018e5:	41                   	inc    %ecx
  8018e6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8018e7:	8a 01                	mov    (%ecx),%al
  8018e9:	84 c0                	test   %al,%al
  8018eb:	74 04                	je     8018f1 <strcmp+0x17>
  8018ed:	3a 02                	cmp    (%edx),%al
  8018ef:	74 f4                	je     8018e5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018f1:	0f b6 c0             	movzbl %al,%eax
  8018f4:	0f b6 12             	movzbl (%edx),%edx
  8018f7:	29 d0                	sub    %edx,%eax
}
  8018f9:	5d                   	pop    %ebp
  8018fa:	c3                   	ret    

008018fb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	53                   	push   %ebx
  8018ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801902:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801905:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801908:	eb 03                	jmp    80190d <strncmp+0x12>
		n--, p++, q++;
  80190a:	4a                   	dec    %edx
  80190b:	40                   	inc    %eax
  80190c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80190d:	85 d2                	test   %edx,%edx
  80190f:	74 14                	je     801925 <strncmp+0x2a>
  801911:	8a 18                	mov    (%eax),%bl
  801913:	84 db                	test   %bl,%bl
  801915:	74 04                	je     80191b <strncmp+0x20>
  801917:	3a 19                	cmp    (%ecx),%bl
  801919:	74 ef                	je     80190a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80191b:	0f b6 00             	movzbl (%eax),%eax
  80191e:	0f b6 11             	movzbl (%ecx),%edx
  801921:	29 d0                	sub    %edx,%eax
  801923:	eb 05                	jmp    80192a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801925:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80192a:	5b                   	pop    %ebx
  80192b:	5d                   	pop    %ebp
  80192c:	c3                   	ret    

0080192d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
  801933:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801936:	eb 05                	jmp    80193d <strchr+0x10>
		if (*s == c)
  801938:	38 ca                	cmp    %cl,%dl
  80193a:	74 0c                	je     801948 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80193c:	40                   	inc    %eax
  80193d:	8a 10                	mov    (%eax),%dl
  80193f:	84 d2                	test   %dl,%dl
  801941:	75 f5                	jne    801938 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801943:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801948:	5d                   	pop    %ebp
  801949:	c3                   	ret    

0080194a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	8b 45 08             	mov    0x8(%ebp),%eax
  801950:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801953:	eb 05                	jmp    80195a <strfind+0x10>
		if (*s == c)
  801955:	38 ca                	cmp    %cl,%dl
  801957:	74 07                	je     801960 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801959:	40                   	inc    %eax
  80195a:	8a 10                	mov    (%eax),%dl
  80195c:	84 d2                	test   %dl,%dl
  80195e:	75 f5                	jne    801955 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801960:	5d                   	pop    %ebp
  801961:	c3                   	ret    

00801962 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	57                   	push   %edi
  801966:	56                   	push   %esi
  801967:	53                   	push   %ebx
  801968:	8b 7d 08             	mov    0x8(%ebp),%edi
  80196b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801971:	85 c9                	test   %ecx,%ecx
  801973:	74 30                	je     8019a5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801975:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80197b:	75 25                	jne    8019a2 <memset+0x40>
  80197d:	f6 c1 03             	test   $0x3,%cl
  801980:	75 20                	jne    8019a2 <memset+0x40>
		c &= 0xFF;
  801982:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801985:	89 d3                	mov    %edx,%ebx
  801987:	c1 e3 08             	shl    $0x8,%ebx
  80198a:	89 d6                	mov    %edx,%esi
  80198c:	c1 e6 18             	shl    $0x18,%esi
  80198f:	89 d0                	mov    %edx,%eax
  801991:	c1 e0 10             	shl    $0x10,%eax
  801994:	09 f0                	or     %esi,%eax
  801996:	09 d0                	or     %edx,%eax
  801998:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80199a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80199d:	fc                   	cld    
  80199e:	f3 ab                	rep stos %eax,%es:(%edi)
  8019a0:	eb 03                	jmp    8019a5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8019a2:	fc                   	cld    
  8019a3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8019a5:	89 f8                	mov    %edi,%eax
  8019a7:	5b                   	pop    %ebx
  8019a8:	5e                   	pop    %esi
  8019a9:	5f                   	pop    %edi
  8019aa:	5d                   	pop    %ebp
  8019ab:	c3                   	ret    

008019ac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	57                   	push   %edi
  8019b0:	56                   	push   %esi
  8019b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8019ba:	39 c6                	cmp    %eax,%esi
  8019bc:	73 34                	jae    8019f2 <memmove+0x46>
  8019be:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8019c1:	39 d0                	cmp    %edx,%eax
  8019c3:	73 2d                	jae    8019f2 <memmove+0x46>
		s += n;
		d += n;
  8019c5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019c8:	f6 c2 03             	test   $0x3,%dl
  8019cb:	75 1b                	jne    8019e8 <memmove+0x3c>
  8019cd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019d3:	75 13                	jne    8019e8 <memmove+0x3c>
  8019d5:	f6 c1 03             	test   $0x3,%cl
  8019d8:	75 0e                	jne    8019e8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019da:	83 ef 04             	sub    $0x4,%edi
  8019dd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019e0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8019e3:	fd                   	std    
  8019e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019e6:	eb 07                	jmp    8019ef <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019e8:	4f                   	dec    %edi
  8019e9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8019ec:	fd                   	std    
  8019ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019ef:	fc                   	cld    
  8019f0:	eb 20                	jmp    801a12 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019f2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8019f8:	75 13                	jne    801a0d <memmove+0x61>
  8019fa:	a8 03                	test   $0x3,%al
  8019fc:	75 0f                	jne    801a0d <memmove+0x61>
  8019fe:	f6 c1 03             	test   $0x3,%cl
  801a01:	75 0a                	jne    801a0d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a03:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801a06:	89 c7                	mov    %eax,%edi
  801a08:	fc                   	cld    
  801a09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a0b:	eb 05                	jmp    801a12 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801a0d:	89 c7                	mov    %eax,%edi
  801a0f:	fc                   	cld    
  801a10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a12:	5e                   	pop    %esi
  801a13:	5f                   	pop    %edi
  801a14:	5d                   	pop    %ebp
  801a15:	c3                   	ret    

00801a16 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a1c:	8b 45 10             	mov    0x10(%ebp),%eax
  801a1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a26:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2d:	89 04 24             	mov    %eax,(%esp)
  801a30:	e8 77 ff ff ff       	call   8019ac <memmove>
}
  801a35:	c9                   	leave  
  801a36:	c3                   	ret    

00801a37 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	57                   	push   %edi
  801a3b:	56                   	push   %esi
  801a3c:	53                   	push   %ebx
  801a3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a40:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a46:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4b:	eb 16                	jmp    801a63 <memcmp+0x2c>
		if (*s1 != *s2)
  801a4d:	8a 04 17             	mov    (%edi,%edx,1),%al
  801a50:	42                   	inc    %edx
  801a51:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801a55:	38 c8                	cmp    %cl,%al
  801a57:	74 0a                	je     801a63 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801a59:	0f b6 c0             	movzbl %al,%eax
  801a5c:	0f b6 c9             	movzbl %cl,%ecx
  801a5f:	29 c8                	sub    %ecx,%eax
  801a61:	eb 09                	jmp    801a6c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a63:	39 da                	cmp    %ebx,%edx
  801a65:	75 e6                	jne    801a4d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801a67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a6c:	5b                   	pop    %ebx
  801a6d:	5e                   	pop    %esi
  801a6e:	5f                   	pop    %edi
  801a6f:	5d                   	pop    %ebp
  801a70:	c3                   	ret    

00801a71 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	8b 45 08             	mov    0x8(%ebp),%eax
  801a77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a7a:	89 c2                	mov    %eax,%edx
  801a7c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a7f:	eb 05                	jmp    801a86 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a81:	38 08                	cmp    %cl,(%eax)
  801a83:	74 05                	je     801a8a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801a85:	40                   	inc    %eax
  801a86:	39 d0                	cmp    %edx,%eax
  801a88:	72 f7                	jb     801a81 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801a8a:	5d                   	pop    %ebp
  801a8b:	c3                   	ret    

00801a8c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	57                   	push   %edi
  801a90:	56                   	push   %esi
  801a91:	53                   	push   %ebx
  801a92:	8b 55 08             	mov    0x8(%ebp),%edx
  801a95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a98:	eb 01                	jmp    801a9b <strtol+0xf>
		s++;
  801a9a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a9b:	8a 02                	mov    (%edx),%al
  801a9d:	3c 20                	cmp    $0x20,%al
  801a9f:	74 f9                	je     801a9a <strtol+0xe>
  801aa1:	3c 09                	cmp    $0x9,%al
  801aa3:	74 f5                	je     801a9a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801aa5:	3c 2b                	cmp    $0x2b,%al
  801aa7:	75 08                	jne    801ab1 <strtol+0x25>
		s++;
  801aa9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801aaa:	bf 00 00 00 00       	mov    $0x0,%edi
  801aaf:	eb 13                	jmp    801ac4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ab1:	3c 2d                	cmp    $0x2d,%al
  801ab3:	75 0a                	jne    801abf <strtol+0x33>
		s++, neg = 1;
  801ab5:	8d 52 01             	lea    0x1(%edx),%edx
  801ab8:	bf 01 00 00 00       	mov    $0x1,%edi
  801abd:	eb 05                	jmp    801ac4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801abf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ac4:	85 db                	test   %ebx,%ebx
  801ac6:	74 05                	je     801acd <strtol+0x41>
  801ac8:	83 fb 10             	cmp    $0x10,%ebx
  801acb:	75 28                	jne    801af5 <strtol+0x69>
  801acd:	8a 02                	mov    (%edx),%al
  801acf:	3c 30                	cmp    $0x30,%al
  801ad1:	75 10                	jne    801ae3 <strtol+0x57>
  801ad3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801ad7:	75 0a                	jne    801ae3 <strtol+0x57>
		s += 2, base = 16;
  801ad9:	83 c2 02             	add    $0x2,%edx
  801adc:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ae1:	eb 12                	jmp    801af5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801ae3:	85 db                	test   %ebx,%ebx
  801ae5:	75 0e                	jne    801af5 <strtol+0x69>
  801ae7:	3c 30                	cmp    $0x30,%al
  801ae9:	75 05                	jne    801af0 <strtol+0x64>
		s++, base = 8;
  801aeb:	42                   	inc    %edx
  801aec:	b3 08                	mov    $0x8,%bl
  801aee:	eb 05                	jmp    801af5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801af0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801af5:	b8 00 00 00 00       	mov    $0x0,%eax
  801afa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801afc:	8a 0a                	mov    (%edx),%cl
  801afe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801b01:	80 fb 09             	cmp    $0x9,%bl
  801b04:	77 08                	ja     801b0e <strtol+0x82>
			dig = *s - '0';
  801b06:	0f be c9             	movsbl %cl,%ecx
  801b09:	83 e9 30             	sub    $0x30,%ecx
  801b0c:	eb 1e                	jmp    801b2c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801b0e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801b11:	80 fb 19             	cmp    $0x19,%bl
  801b14:	77 08                	ja     801b1e <strtol+0x92>
			dig = *s - 'a' + 10;
  801b16:	0f be c9             	movsbl %cl,%ecx
  801b19:	83 e9 57             	sub    $0x57,%ecx
  801b1c:	eb 0e                	jmp    801b2c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801b1e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801b21:	80 fb 19             	cmp    $0x19,%bl
  801b24:	77 12                	ja     801b38 <strtol+0xac>
			dig = *s - 'A' + 10;
  801b26:	0f be c9             	movsbl %cl,%ecx
  801b29:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801b2c:	39 f1                	cmp    %esi,%ecx
  801b2e:	7d 0c                	jge    801b3c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801b30:	42                   	inc    %edx
  801b31:	0f af c6             	imul   %esi,%eax
  801b34:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801b36:	eb c4                	jmp    801afc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801b38:	89 c1                	mov    %eax,%ecx
  801b3a:	eb 02                	jmp    801b3e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801b3c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801b3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b42:	74 05                	je     801b49 <strtol+0xbd>
		*endptr = (char *) s;
  801b44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b47:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801b49:	85 ff                	test   %edi,%edi
  801b4b:	74 04                	je     801b51 <strtol+0xc5>
  801b4d:	89 c8                	mov    %ecx,%eax
  801b4f:	f7 d8                	neg    %eax
}
  801b51:	5b                   	pop    %ebx
  801b52:	5e                   	pop    %esi
  801b53:	5f                   	pop    %edi
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    
	...

00801b58 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	56                   	push   %esi
  801b5c:	53                   	push   %ebx
  801b5d:	83 ec 10             	sub    $0x10,%esp
  801b60:	8b 75 08             	mov    0x8(%ebp),%esi
  801b63:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	75 05                	jne    801b72 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801b6d:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801b72:	89 04 24             	mov    %eax,(%esp)
  801b75:	e8 29 e8 ff ff       	call   8003a3 <sys_ipc_recv>
	if (!err) {
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	75 26                	jne    801ba4 <ipc_recv+0x4c>
		if (from_env_store) {
  801b7e:	85 f6                	test   %esi,%esi
  801b80:	74 0a                	je     801b8c <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801b82:	a1 04 40 80 00       	mov    0x804004,%eax
  801b87:	8b 40 74             	mov    0x74(%eax),%eax
  801b8a:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801b8c:	85 db                	test   %ebx,%ebx
  801b8e:	74 0a                	je     801b9a <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801b90:	a1 04 40 80 00       	mov    0x804004,%eax
  801b95:	8b 40 78             	mov    0x78(%eax),%eax
  801b98:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801b9a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b9f:	8b 40 70             	mov    0x70(%eax),%eax
  801ba2:	eb 14                	jmp    801bb8 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801ba4:	85 f6                	test   %esi,%esi
  801ba6:	74 06                	je     801bae <ipc_recv+0x56>
		*from_env_store = 0;
  801ba8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801bae:	85 db                	test   %ebx,%ebx
  801bb0:	74 06                	je     801bb8 <ipc_recv+0x60>
		*perm_store = 0;
  801bb2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	5b                   	pop    %ebx
  801bbc:	5e                   	pop    %esi
  801bbd:	5d                   	pop    %ebp
  801bbe:	c3                   	ret    

00801bbf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	57                   	push   %edi
  801bc3:	56                   	push   %esi
  801bc4:	53                   	push   %ebx
  801bc5:	83 ec 1c             	sub    $0x1c,%esp
  801bc8:	8b 75 10             	mov    0x10(%ebp),%esi
  801bcb:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801bce:	85 f6                	test   %esi,%esi
  801bd0:	75 05                	jne    801bd7 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801bd2:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801bd7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801bdb:	89 74 24 08          	mov    %esi,0x8(%esp)
  801bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be6:	8b 45 08             	mov    0x8(%ebp),%eax
  801be9:	89 04 24             	mov    %eax,(%esp)
  801bec:	e8 8f e7 ff ff       	call   800380 <sys_ipc_try_send>
  801bf1:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801bf3:	e8 76 e5 ff ff       	call   80016e <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801bf8:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801bfb:	74 da                	je     801bd7 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801bfd:	85 db                	test   %ebx,%ebx
  801bff:	74 20                	je     801c21 <ipc_send+0x62>
		panic("send fail: %e", err);
  801c01:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c05:	c7 44 24 08 80 23 80 	movl   $0x802380,0x8(%esp)
  801c0c:	00 
  801c0d:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801c14:	00 
  801c15:	c7 04 24 8e 23 80 00 	movl   $0x80238e,(%esp)
  801c1c:	e8 4f f5 ff ff       	call   801170 <_panic>
	}
	return;
}
  801c21:	83 c4 1c             	add    $0x1c,%esp
  801c24:	5b                   	pop    %ebx
  801c25:	5e                   	pop    %esi
  801c26:	5f                   	pop    %edi
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    

00801c29 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	53                   	push   %ebx
  801c2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c30:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c35:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c3c:	89 c2                	mov    %eax,%edx
  801c3e:	c1 e2 07             	shl    $0x7,%edx
  801c41:	29 ca                	sub    %ecx,%edx
  801c43:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c49:	8b 52 50             	mov    0x50(%edx),%edx
  801c4c:	39 da                	cmp    %ebx,%edx
  801c4e:	75 0f                	jne    801c5f <ipc_find_env+0x36>
			return envs[i].env_id;
  801c50:	c1 e0 07             	shl    $0x7,%eax
  801c53:	29 c8                	sub    %ecx,%eax
  801c55:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c5a:	8b 40 40             	mov    0x40(%eax),%eax
  801c5d:	eb 0c                	jmp    801c6b <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c5f:	40                   	inc    %eax
  801c60:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c65:	75 ce                	jne    801c35 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c67:	66 b8 00 00          	mov    $0x0,%ax
}
  801c6b:	5b                   	pop    %ebx
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    
	...

00801c70 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c76:	89 c2                	mov    %eax,%edx
  801c78:	c1 ea 16             	shr    $0x16,%edx
  801c7b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c82:	f6 c2 01             	test   $0x1,%dl
  801c85:	74 1e                	je     801ca5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c87:	c1 e8 0c             	shr    $0xc,%eax
  801c8a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c91:	a8 01                	test   $0x1,%al
  801c93:	74 17                	je     801cac <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c95:	c1 e8 0c             	shr    $0xc,%eax
  801c98:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c9f:	ef 
  801ca0:	0f b7 c0             	movzwl %ax,%eax
  801ca3:	eb 0c                	jmp    801cb1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801ca5:	b8 00 00 00 00       	mov    $0x0,%eax
  801caa:	eb 05                	jmp    801cb1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801cac:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801cb1:	5d                   	pop    %ebp
  801cb2:	c3                   	ret    
	...

00801cb4 <__udivdi3>:
  801cb4:	55                   	push   %ebp
  801cb5:	57                   	push   %edi
  801cb6:	56                   	push   %esi
  801cb7:	83 ec 10             	sub    $0x10,%esp
  801cba:	8b 74 24 20          	mov    0x20(%esp),%esi
  801cbe:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801cc2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cc6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cca:	89 cd                	mov    %ecx,%ebp
  801ccc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801cd0:	85 c0                	test   %eax,%eax
  801cd2:	75 2c                	jne    801d00 <__udivdi3+0x4c>
  801cd4:	39 f9                	cmp    %edi,%ecx
  801cd6:	77 68                	ja     801d40 <__udivdi3+0x8c>
  801cd8:	85 c9                	test   %ecx,%ecx
  801cda:	75 0b                	jne    801ce7 <__udivdi3+0x33>
  801cdc:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce1:	31 d2                	xor    %edx,%edx
  801ce3:	f7 f1                	div    %ecx
  801ce5:	89 c1                	mov    %eax,%ecx
  801ce7:	31 d2                	xor    %edx,%edx
  801ce9:	89 f8                	mov    %edi,%eax
  801ceb:	f7 f1                	div    %ecx
  801ced:	89 c7                	mov    %eax,%edi
  801cef:	89 f0                	mov    %esi,%eax
  801cf1:	f7 f1                	div    %ecx
  801cf3:	89 c6                	mov    %eax,%esi
  801cf5:	89 f0                	mov    %esi,%eax
  801cf7:	89 fa                	mov    %edi,%edx
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	5e                   	pop    %esi
  801cfd:	5f                   	pop    %edi
  801cfe:	5d                   	pop    %ebp
  801cff:	c3                   	ret    
  801d00:	39 f8                	cmp    %edi,%eax
  801d02:	77 2c                	ja     801d30 <__udivdi3+0x7c>
  801d04:	0f bd f0             	bsr    %eax,%esi
  801d07:	83 f6 1f             	xor    $0x1f,%esi
  801d0a:	75 4c                	jne    801d58 <__udivdi3+0xa4>
  801d0c:	39 f8                	cmp    %edi,%eax
  801d0e:	bf 00 00 00 00       	mov    $0x0,%edi
  801d13:	72 0a                	jb     801d1f <__udivdi3+0x6b>
  801d15:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d19:	0f 87 ad 00 00 00    	ja     801dcc <__udivdi3+0x118>
  801d1f:	be 01 00 00 00       	mov    $0x1,%esi
  801d24:	89 f0                	mov    %esi,%eax
  801d26:	89 fa                	mov    %edi,%edx
  801d28:	83 c4 10             	add    $0x10,%esp
  801d2b:	5e                   	pop    %esi
  801d2c:	5f                   	pop    %edi
  801d2d:	5d                   	pop    %ebp
  801d2e:	c3                   	ret    
  801d2f:	90                   	nop
  801d30:	31 ff                	xor    %edi,%edi
  801d32:	31 f6                	xor    %esi,%esi
  801d34:	89 f0                	mov    %esi,%eax
  801d36:	89 fa                	mov    %edi,%edx
  801d38:	83 c4 10             	add    $0x10,%esp
  801d3b:	5e                   	pop    %esi
  801d3c:	5f                   	pop    %edi
  801d3d:	5d                   	pop    %ebp
  801d3e:	c3                   	ret    
  801d3f:	90                   	nop
  801d40:	89 fa                	mov    %edi,%edx
  801d42:	89 f0                	mov    %esi,%eax
  801d44:	f7 f1                	div    %ecx
  801d46:	89 c6                	mov    %eax,%esi
  801d48:	31 ff                	xor    %edi,%edi
  801d4a:	89 f0                	mov    %esi,%eax
  801d4c:	89 fa                	mov    %edi,%edx
  801d4e:	83 c4 10             	add    $0x10,%esp
  801d51:	5e                   	pop    %esi
  801d52:	5f                   	pop    %edi
  801d53:	5d                   	pop    %ebp
  801d54:	c3                   	ret    
  801d55:	8d 76 00             	lea    0x0(%esi),%esi
  801d58:	89 f1                	mov    %esi,%ecx
  801d5a:	d3 e0                	shl    %cl,%eax
  801d5c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d60:	b8 20 00 00 00       	mov    $0x20,%eax
  801d65:	29 f0                	sub    %esi,%eax
  801d67:	89 ea                	mov    %ebp,%edx
  801d69:	88 c1                	mov    %al,%cl
  801d6b:	d3 ea                	shr    %cl,%edx
  801d6d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801d71:	09 ca                	or     %ecx,%edx
  801d73:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d77:	89 f1                	mov    %esi,%ecx
  801d79:	d3 e5                	shl    %cl,%ebp
  801d7b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801d7f:	89 fd                	mov    %edi,%ebp
  801d81:	88 c1                	mov    %al,%cl
  801d83:	d3 ed                	shr    %cl,%ebp
  801d85:	89 fa                	mov    %edi,%edx
  801d87:	89 f1                	mov    %esi,%ecx
  801d89:	d3 e2                	shl    %cl,%edx
  801d8b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d8f:	88 c1                	mov    %al,%cl
  801d91:	d3 ef                	shr    %cl,%edi
  801d93:	09 d7                	or     %edx,%edi
  801d95:	89 f8                	mov    %edi,%eax
  801d97:	89 ea                	mov    %ebp,%edx
  801d99:	f7 74 24 08          	divl   0x8(%esp)
  801d9d:	89 d1                	mov    %edx,%ecx
  801d9f:	89 c7                	mov    %eax,%edi
  801da1:	f7 64 24 0c          	mull   0xc(%esp)
  801da5:	39 d1                	cmp    %edx,%ecx
  801da7:	72 17                	jb     801dc0 <__udivdi3+0x10c>
  801da9:	74 09                	je     801db4 <__udivdi3+0x100>
  801dab:	89 fe                	mov    %edi,%esi
  801dad:	31 ff                	xor    %edi,%edi
  801daf:	e9 41 ff ff ff       	jmp    801cf5 <__udivdi3+0x41>
  801db4:	8b 54 24 04          	mov    0x4(%esp),%edx
  801db8:	89 f1                	mov    %esi,%ecx
  801dba:	d3 e2                	shl    %cl,%edx
  801dbc:	39 c2                	cmp    %eax,%edx
  801dbe:	73 eb                	jae    801dab <__udivdi3+0xf7>
  801dc0:	8d 77 ff             	lea    -0x1(%edi),%esi
  801dc3:	31 ff                	xor    %edi,%edi
  801dc5:	e9 2b ff ff ff       	jmp    801cf5 <__udivdi3+0x41>
  801dca:	66 90                	xchg   %ax,%ax
  801dcc:	31 f6                	xor    %esi,%esi
  801dce:	e9 22 ff ff ff       	jmp    801cf5 <__udivdi3+0x41>
	...

00801dd4 <__umoddi3>:
  801dd4:	55                   	push   %ebp
  801dd5:	57                   	push   %edi
  801dd6:	56                   	push   %esi
  801dd7:	83 ec 20             	sub    $0x20,%esp
  801dda:	8b 44 24 30          	mov    0x30(%esp),%eax
  801dde:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801de2:	89 44 24 14          	mov    %eax,0x14(%esp)
  801de6:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dea:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dee:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801df2:	89 c7                	mov    %eax,%edi
  801df4:	89 f2                	mov    %esi,%edx
  801df6:	85 ed                	test   %ebp,%ebp
  801df8:	75 16                	jne    801e10 <__umoddi3+0x3c>
  801dfa:	39 f1                	cmp    %esi,%ecx
  801dfc:	0f 86 a6 00 00 00    	jbe    801ea8 <__umoddi3+0xd4>
  801e02:	f7 f1                	div    %ecx
  801e04:	89 d0                	mov    %edx,%eax
  801e06:	31 d2                	xor    %edx,%edx
  801e08:	83 c4 20             	add    $0x20,%esp
  801e0b:	5e                   	pop    %esi
  801e0c:	5f                   	pop    %edi
  801e0d:	5d                   	pop    %ebp
  801e0e:	c3                   	ret    
  801e0f:	90                   	nop
  801e10:	39 f5                	cmp    %esi,%ebp
  801e12:	0f 87 ac 00 00 00    	ja     801ec4 <__umoddi3+0xf0>
  801e18:	0f bd c5             	bsr    %ebp,%eax
  801e1b:	83 f0 1f             	xor    $0x1f,%eax
  801e1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e22:	0f 84 a8 00 00 00    	je     801ed0 <__umoddi3+0xfc>
  801e28:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e2c:	d3 e5                	shl    %cl,%ebp
  801e2e:	bf 20 00 00 00       	mov    $0x20,%edi
  801e33:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e37:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e3b:	89 f9                	mov    %edi,%ecx
  801e3d:	d3 e8                	shr    %cl,%eax
  801e3f:	09 e8                	or     %ebp,%eax
  801e41:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e45:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e49:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e4d:	d3 e0                	shl    %cl,%eax
  801e4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e53:	89 f2                	mov    %esi,%edx
  801e55:	d3 e2                	shl    %cl,%edx
  801e57:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e5b:	d3 e0                	shl    %cl,%eax
  801e5d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801e61:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e65:	89 f9                	mov    %edi,%ecx
  801e67:	d3 e8                	shr    %cl,%eax
  801e69:	09 d0                	or     %edx,%eax
  801e6b:	d3 ee                	shr    %cl,%esi
  801e6d:	89 f2                	mov    %esi,%edx
  801e6f:	f7 74 24 18          	divl   0x18(%esp)
  801e73:	89 d6                	mov    %edx,%esi
  801e75:	f7 64 24 0c          	mull   0xc(%esp)
  801e79:	89 c5                	mov    %eax,%ebp
  801e7b:	89 d1                	mov    %edx,%ecx
  801e7d:	39 d6                	cmp    %edx,%esi
  801e7f:	72 67                	jb     801ee8 <__umoddi3+0x114>
  801e81:	74 75                	je     801ef8 <__umoddi3+0x124>
  801e83:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e87:	29 e8                	sub    %ebp,%eax
  801e89:	19 ce                	sbb    %ecx,%esi
  801e8b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e8f:	d3 e8                	shr    %cl,%eax
  801e91:	89 f2                	mov    %esi,%edx
  801e93:	89 f9                	mov    %edi,%ecx
  801e95:	d3 e2                	shl    %cl,%edx
  801e97:	09 d0                	or     %edx,%eax
  801e99:	89 f2                	mov    %esi,%edx
  801e9b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e9f:	d3 ea                	shr    %cl,%edx
  801ea1:	83 c4 20             	add    $0x20,%esp
  801ea4:	5e                   	pop    %esi
  801ea5:	5f                   	pop    %edi
  801ea6:	5d                   	pop    %ebp
  801ea7:	c3                   	ret    
  801ea8:	85 c9                	test   %ecx,%ecx
  801eaa:	75 0b                	jne    801eb7 <__umoddi3+0xe3>
  801eac:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb1:	31 d2                	xor    %edx,%edx
  801eb3:	f7 f1                	div    %ecx
  801eb5:	89 c1                	mov    %eax,%ecx
  801eb7:	89 f0                	mov    %esi,%eax
  801eb9:	31 d2                	xor    %edx,%edx
  801ebb:	f7 f1                	div    %ecx
  801ebd:	89 f8                	mov    %edi,%eax
  801ebf:	e9 3e ff ff ff       	jmp    801e02 <__umoddi3+0x2e>
  801ec4:	89 f2                	mov    %esi,%edx
  801ec6:	83 c4 20             	add    $0x20,%esp
  801ec9:	5e                   	pop    %esi
  801eca:	5f                   	pop    %edi
  801ecb:	5d                   	pop    %ebp
  801ecc:	c3                   	ret    
  801ecd:	8d 76 00             	lea    0x0(%esi),%esi
  801ed0:	39 f5                	cmp    %esi,%ebp
  801ed2:	72 04                	jb     801ed8 <__umoddi3+0x104>
  801ed4:	39 f9                	cmp    %edi,%ecx
  801ed6:	77 06                	ja     801ede <__umoddi3+0x10a>
  801ed8:	89 f2                	mov    %esi,%edx
  801eda:	29 cf                	sub    %ecx,%edi
  801edc:	19 ea                	sbb    %ebp,%edx
  801ede:	89 f8                	mov    %edi,%eax
  801ee0:	83 c4 20             	add    $0x20,%esp
  801ee3:	5e                   	pop    %esi
  801ee4:	5f                   	pop    %edi
  801ee5:	5d                   	pop    %ebp
  801ee6:	c3                   	ret    
  801ee7:	90                   	nop
  801ee8:	89 d1                	mov    %edx,%ecx
  801eea:	89 c5                	mov    %eax,%ebp
  801eec:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801ef0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801ef4:	eb 8d                	jmp    801e83 <__umoddi3+0xaf>
  801ef6:	66 90                	xchg   %ax,%ax
  801ef8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801efc:	72 ea                	jb     801ee8 <__umoddi3+0x114>
  801efe:	89 f1                	mov    %esi,%ecx
  801f00:	eb 81                	jmp    801e83 <__umoddi3+0xaf>

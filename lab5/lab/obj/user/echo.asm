
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
  80003d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800040:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800043:	83 ff 01             	cmp    $0x1,%edi
  800046:	7e 24                	jle    80006c <umain+0x38>
  800048:	c7 44 24 04 c0 1f 80 	movl   $0x801fc0,0x4(%esp)
  80004f:	00 
  800050:	8b 46 04             	mov    0x4(%esi),%eax
  800053:	89 04 24             	mov    %eax,(%esp)
  800056:	e8 e7 01 00 00       	call   800242 <strcmp>
  80005b:	85 c0                	test   %eax,%eax
  80005d:	75 16                	jne    800075 <umain+0x41>
		nflag = 1;
		argc--;
  80005f:	4f                   	dec    %edi
		argv++;
  800060:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800063:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  80006a:	eb 10                	jmp    80007c <umain+0x48>
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  80006c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800073:	eb 07                	jmp    80007c <umain+0x48>
  800075:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  80007c:	bb 01 00 00 00       	mov    $0x1,%ebx
  800081:	eb 44                	jmp    8000c7 <umain+0x93>
		if (i > 1)
  800083:	83 fb 01             	cmp    $0x1,%ebx
  800086:	7e 1c                	jle    8000a4 <umain+0x70>
			write(1, " ", 1);
  800088:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80008f:	00 
  800090:	c7 44 24 04 c3 1f 80 	movl   $0x801fc3,0x4(%esp)
  800097:	00 
  800098:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80009f:	e8 49 0b 00 00       	call   800bed <write>
		write(1, argv[i], strlen(argv[i]));
  8000a4:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000a7:	89 04 24             	mov    %eax,(%esp)
  8000aa:	e8 b9 00 00 00       	call   800168 <strlen>
  8000af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b3:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000c1:	e8 27 0b 00 00       	call   800bed <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000c6:	43                   	inc    %ebx
  8000c7:	39 df                	cmp    %ebx,%edi
  8000c9:	7f b8                	jg     800083 <umain+0x4f>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000cf:	75 1c                	jne    8000ed <umain+0xb9>
		write(1, "\n", 1);
  8000d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000d8:	00 
  8000d9:	c7 44 24 04 f1 20 80 	movl   $0x8020f1,0x4(%esp)
  8000e0:	00 
  8000e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000e8:	e8 00 0b 00 00       	call   800bed <write>
}
  8000ed:	83 c4 2c             	add    $0x2c,%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 10             	sub    $0x10,%esp
  800100:	8b 75 08             	mov    0x8(%ebp),%esi
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800106:	e8 44 04 00 00       	call   80054f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800117:	c1 e0 07             	shl    $0x7,%eax
  80011a:	29 d0                	sub    %edx,%eax
  80011c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800121:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800126:	85 f6                	test   %esi,%esi
  800128:	7e 07                	jle    800131 <libmain+0x39>
		binaryname = argv[0];
  80012a:	8b 03                	mov    (%ebx),%eax
  80012c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800135:	89 34 24             	mov    %esi,(%esp)
  800138:	e8 f7 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80013d:	e8 0a 00 00 00       	call   80014c <exit>
}
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800152:	e8 88 08 00 00       	call   8009df <close_all>
	sys_env_destroy(0);
  800157:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015e:	e8 9a 03 00 00       	call   8004fd <sys_env_destroy>
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    
  800165:	00 00                	add    %al,(%eax)
	...

00800168 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80016e:	b8 00 00 00 00       	mov    $0x0,%eax
  800173:	eb 01                	jmp    800176 <strlen+0xe>
		n++;
  800175:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800176:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80017a:	75 f9                	jne    800175 <strlen+0xd>
		n++;
	return n;
}
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    

0080017e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800184:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800187:	b8 00 00 00 00       	mov    $0x0,%eax
  80018c:	eb 01                	jmp    80018f <strnlen+0x11>
		n++;
  80018e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80018f:	39 d0                	cmp    %edx,%eax
  800191:	74 06                	je     800199 <strnlen+0x1b>
  800193:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800197:	75 f5                	jne    80018e <strnlen+0x10>
		n++;
	return n;
}
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    

0080019b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	53                   	push   %ebx
  80019f:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8001a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001aa:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8001ad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8001b0:	42                   	inc    %edx
  8001b1:	84 c9                	test   %cl,%cl
  8001b3:	75 f5                	jne    8001aa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8001b5:	5b                   	pop    %ebx
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001c2:	89 1c 24             	mov    %ebx,(%esp)
  8001c5:	e8 9e ff ff ff       	call   800168 <strlen>
	strcpy(dst + len, src);
  8001ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001d1:	01 d8                	add    %ebx,%eax
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	e8 c0 ff ff ff       	call   80019b <strcpy>
	return dst;
}
  8001db:	89 d8                	mov    %ebx,%eax
  8001dd:	83 c4 08             	add    $0x8,%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	56                   	push   %esi
  8001e7:	53                   	push   %ebx
  8001e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ee:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001f6:	eb 0c                	jmp    800204 <strncpy+0x21>
		*dst++ = *src;
  8001f8:	8a 1a                	mov    (%edx),%bl
  8001fa:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001fd:	80 3a 01             	cmpb   $0x1,(%edx)
  800200:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800203:	41                   	inc    %ecx
  800204:	39 f1                	cmp    %esi,%ecx
  800206:	75 f0                	jne    8001f8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800208:	5b                   	pop    %ebx
  800209:	5e                   	pop    %esi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    

0080020c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	56                   	push   %esi
  800210:	53                   	push   %ebx
  800211:	8b 75 08             	mov    0x8(%ebp),%esi
  800214:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800217:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80021a:	85 d2                	test   %edx,%edx
  80021c:	75 0a                	jne    800228 <strlcpy+0x1c>
  80021e:	89 f0                	mov    %esi,%eax
  800220:	eb 1a                	jmp    80023c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800222:	88 18                	mov    %bl,(%eax)
  800224:	40                   	inc    %eax
  800225:	41                   	inc    %ecx
  800226:	eb 02                	jmp    80022a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800228:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80022a:	4a                   	dec    %edx
  80022b:	74 0a                	je     800237 <strlcpy+0x2b>
  80022d:	8a 19                	mov    (%ecx),%bl
  80022f:	84 db                	test   %bl,%bl
  800231:	75 ef                	jne    800222 <strlcpy+0x16>
  800233:	89 c2                	mov    %eax,%edx
  800235:	eb 02                	jmp    800239 <strlcpy+0x2d>
  800237:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800239:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80023c:	29 f0                	sub    %esi,%eax
}
  80023e:	5b                   	pop    %ebx
  80023f:	5e                   	pop    %esi
  800240:	5d                   	pop    %ebp
  800241:	c3                   	ret    

00800242 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
  800245:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800248:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80024b:	eb 02                	jmp    80024f <strcmp+0xd>
		p++, q++;
  80024d:	41                   	inc    %ecx
  80024e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80024f:	8a 01                	mov    (%ecx),%al
  800251:	84 c0                	test   %al,%al
  800253:	74 04                	je     800259 <strcmp+0x17>
  800255:	3a 02                	cmp    (%edx),%al
  800257:	74 f4                	je     80024d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800259:	0f b6 c0             	movzbl %al,%eax
  80025c:	0f b6 12             	movzbl (%edx),%edx
  80025f:	29 d0                	sub    %edx,%eax
}
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	53                   	push   %ebx
  800267:	8b 45 08             	mov    0x8(%ebp),%eax
  80026a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800270:	eb 03                	jmp    800275 <strncmp+0x12>
		n--, p++, q++;
  800272:	4a                   	dec    %edx
  800273:	40                   	inc    %eax
  800274:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800275:	85 d2                	test   %edx,%edx
  800277:	74 14                	je     80028d <strncmp+0x2a>
  800279:	8a 18                	mov    (%eax),%bl
  80027b:	84 db                	test   %bl,%bl
  80027d:	74 04                	je     800283 <strncmp+0x20>
  80027f:	3a 19                	cmp    (%ecx),%bl
  800281:	74 ef                	je     800272 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800283:	0f b6 00             	movzbl (%eax),%eax
  800286:	0f b6 11             	movzbl (%ecx),%edx
  800289:	29 d0                	sub    %edx,%eax
  80028b:	eb 05                	jmp    800292 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80028d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800292:	5b                   	pop    %ebx
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	8b 45 08             	mov    0x8(%ebp),%eax
  80029b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80029e:	eb 05                	jmp    8002a5 <strchr+0x10>
		if (*s == c)
  8002a0:	38 ca                	cmp    %cl,%dl
  8002a2:	74 0c                	je     8002b0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8002a4:	40                   	inc    %eax
  8002a5:	8a 10                	mov    (%eax),%dl
  8002a7:	84 d2                	test   %dl,%dl
  8002a9:	75 f5                	jne    8002a0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8002ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8002bb:	eb 05                	jmp    8002c2 <strfind+0x10>
		if (*s == c)
  8002bd:	38 ca                	cmp    %cl,%dl
  8002bf:	74 07                	je     8002c8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8002c1:	40                   	inc    %eax
  8002c2:	8a 10                	mov    (%eax),%dl
  8002c4:	84 d2                	test   %dl,%dl
  8002c6:	75 f5                	jne    8002bd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	57                   	push   %edi
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002d9:	85 c9                	test   %ecx,%ecx
  8002db:	74 30                	je     80030d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002dd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002e3:	75 25                	jne    80030a <memset+0x40>
  8002e5:	f6 c1 03             	test   $0x3,%cl
  8002e8:	75 20                	jne    80030a <memset+0x40>
		c &= 0xFF;
  8002ea:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002ed:	89 d3                	mov    %edx,%ebx
  8002ef:	c1 e3 08             	shl    $0x8,%ebx
  8002f2:	89 d6                	mov    %edx,%esi
  8002f4:	c1 e6 18             	shl    $0x18,%esi
  8002f7:	89 d0                	mov    %edx,%eax
  8002f9:	c1 e0 10             	shl    $0x10,%eax
  8002fc:	09 f0                	or     %esi,%eax
  8002fe:	09 d0                	or     %edx,%eax
  800300:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800302:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800305:	fc                   	cld    
  800306:	f3 ab                	rep stos %eax,%es:(%edi)
  800308:	eb 03                	jmp    80030d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80030a:	fc                   	cld    
  80030b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80030d:	89 f8                	mov    %edi,%eax
  80030f:	5b                   	pop    %ebx
  800310:	5e                   	pop    %esi
  800311:	5f                   	pop    %edi
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    

00800314 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	57                   	push   %edi
  800318:	56                   	push   %esi
  800319:	8b 45 08             	mov    0x8(%ebp),%eax
  80031c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80031f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800322:	39 c6                	cmp    %eax,%esi
  800324:	73 34                	jae    80035a <memmove+0x46>
  800326:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800329:	39 d0                	cmp    %edx,%eax
  80032b:	73 2d                	jae    80035a <memmove+0x46>
		s += n;
		d += n;
  80032d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800330:	f6 c2 03             	test   $0x3,%dl
  800333:	75 1b                	jne    800350 <memmove+0x3c>
  800335:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80033b:	75 13                	jne    800350 <memmove+0x3c>
  80033d:	f6 c1 03             	test   $0x3,%cl
  800340:	75 0e                	jne    800350 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800342:	83 ef 04             	sub    $0x4,%edi
  800345:	8d 72 fc             	lea    -0x4(%edx),%esi
  800348:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80034b:	fd                   	std    
  80034c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80034e:	eb 07                	jmp    800357 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800350:	4f                   	dec    %edi
  800351:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800354:	fd                   	std    
  800355:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800357:	fc                   	cld    
  800358:	eb 20                	jmp    80037a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80035a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800360:	75 13                	jne    800375 <memmove+0x61>
  800362:	a8 03                	test   $0x3,%al
  800364:	75 0f                	jne    800375 <memmove+0x61>
  800366:	f6 c1 03             	test   $0x3,%cl
  800369:	75 0a                	jne    800375 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80036b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80036e:	89 c7                	mov    %eax,%edi
  800370:	fc                   	cld    
  800371:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800373:	eb 05                	jmp    80037a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800375:	89 c7                	mov    %eax,%edi
  800377:	fc                   	cld    
  800378:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80037a:	5e                   	pop    %esi
  80037b:	5f                   	pop    %edi
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800384:	8b 45 10             	mov    0x10(%ebp),%eax
  800387:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80038e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	89 04 24             	mov    %eax,(%esp)
  800398:	e8 77 ff ff ff       	call   800314 <memmove>
}
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	57                   	push   %edi
  8003a3:	56                   	push   %esi
  8003a4:	53                   	push   %ebx
  8003a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b3:	eb 16                	jmp    8003cb <memcmp+0x2c>
		if (*s1 != *s2)
  8003b5:	8a 04 17             	mov    (%edi,%edx,1),%al
  8003b8:	42                   	inc    %edx
  8003b9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8003bd:	38 c8                	cmp    %cl,%al
  8003bf:	74 0a                	je     8003cb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8003c1:	0f b6 c0             	movzbl %al,%eax
  8003c4:	0f b6 c9             	movzbl %cl,%ecx
  8003c7:	29 c8                	sub    %ecx,%eax
  8003c9:	eb 09                	jmp    8003d4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003cb:	39 da                	cmp    %ebx,%edx
  8003cd:	75 e6                	jne    8003b5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003d4:	5b                   	pop    %ebx
  8003d5:	5e                   	pop    %esi
  8003d6:	5f                   	pop    %edi
  8003d7:	5d                   	pop    %ebp
  8003d8:	c3                   	ret    

008003d9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003d9:	55                   	push   %ebp
  8003da:	89 e5                	mov    %esp,%ebp
  8003dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8003e2:	89 c2                	mov    %eax,%edx
  8003e4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8003e7:	eb 05                	jmp    8003ee <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003e9:	38 08                	cmp    %cl,(%eax)
  8003eb:	74 05                	je     8003f2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003ed:	40                   	inc    %eax
  8003ee:	39 d0                	cmp    %edx,%eax
  8003f0:	72 f7                	jb     8003e9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	57                   	push   %edi
  8003f8:	56                   	push   %esi
  8003f9:	53                   	push   %ebx
  8003fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800400:	eb 01                	jmp    800403 <strtol+0xf>
		s++;
  800402:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800403:	8a 02                	mov    (%edx),%al
  800405:	3c 20                	cmp    $0x20,%al
  800407:	74 f9                	je     800402 <strtol+0xe>
  800409:	3c 09                	cmp    $0x9,%al
  80040b:	74 f5                	je     800402 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80040d:	3c 2b                	cmp    $0x2b,%al
  80040f:	75 08                	jne    800419 <strtol+0x25>
		s++;
  800411:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800412:	bf 00 00 00 00       	mov    $0x0,%edi
  800417:	eb 13                	jmp    80042c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800419:	3c 2d                	cmp    $0x2d,%al
  80041b:	75 0a                	jne    800427 <strtol+0x33>
		s++, neg = 1;
  80041d:	8d 52 01             	lea    0x1(%edx),%edx
  800420:	bf 01 00 00 00       	mov    $0x1,%edi
  800425:	eb 05                	jmp    80042c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800427:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80042c:	85 db                	test   %ebx,%ebx
  80042e:	74 05                	je     800435 <strtol+0x41>
  800430:	83 fb 10             	cmp    $0x10,%ebx
  800433:	75 28                	jne    80045d <strtol+0x69>
  800435:	8a 02                	mov    (%edx),%al
  800437:	3c 30                	cmp    $0x30,%al
  800439:	75 10                	jne    80044b <strtol+0x57>
  80043b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80043f:	75 0a                	jne    80044b <strtol+0x57>
		s += 2, base = 16;
  800441:	83 c2 02             	add    $0x2,%edx
  800444:	bb 10 00 00 00       	mov    $0x10,%ebx
  800449:	eb 12                	jmp    80045d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80044b:	85 db                	test   %ebx,%ebx
  80044d:	75 0e                	jne    80045d <strtol+0x69>
  80044f:	3c 30                	cmp    $0x30,%al
  800451:	75 05                	jne    800458 <strtol+0x64>
		s++, base = 8;
  800453:	42                   	inc    %edx
  800454:	b3 08                	mov    $0x8,%bl
  800456:	eb 05                	jmp    80045d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800458:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80045d:	b8 00 00 00 00       	mov    $0x0,%eax
  800462:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800464:	8a 0a                	mov    (%edx),%cl
  800466:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800469:	80 fb 09             	cmp    $0x9,%bl
  80046c:	77 08                	ja     800476 <strtol+0x82>
			dig = *s - '0';
  80046e:	0f be c9             	movsbl %cl,%ecx
  800471:	83 e9 30             	sub    $0x30,%ecx
  800474:	eb 1e                	jmp    800494 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800476:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800479:	80 fb 19             	cmp    $0x19,%bl
  80047c:	77 08                	ja     800486 <strtol+0x92>
			dig = *s - 'a' + 10;
  80047e:	0f be c9             	movsbl %cl,%ecx
  800481:	83 e9 57             	sub    $0x57,%ecx
  800484:	eb 0e                	jmp    800494 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800486:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800489:	80 fb 19             	cmp    $0x19,%bl
  80048c:	77 12                	ja     8004a0 <strtol+0xac>
			dig = *s - 'A' + 10;
  80048e:	0f be c9             	movsbl %cl,%ecx
  800491:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800494:	39 f1                	cmp    %esi,%ecx
  800496:	7d 0c                	jge    8004a4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800498:	42                   	inc    %edx
  800499:	0f af c6             	imul   %esi,%eax
  80049c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80049e:	eb c4                	jmp    800464 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8004a0:	89 c1                	mov    %eax,%ecx
  8004a2:	eb 02                	jmp    8004a6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8004a4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8004a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004aa:	74 05                	je     8004b1 <strtol+0xbd>
		*endptr = (char *) s;
  8004ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004af:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8004b1:	85 ff                	test   %edi,%edi
  8004b3:	74 04                	je     8004b9 <strtol+0xc5>
  8004b5:	89 c8                	mov    %ecx,%eax
  8004b7:	f7 d8                	neg    %eax
}
  8004b9:	5b                   	pop    %ebx
  8004ba:	5e                   	pop    %esi
  8004bb:	5f                   	pop    %edi
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    
	...

008004c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	57                   	push   %edi
  8004c4:	56                   	push   %esi
  8004c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d1:	89 c3                	mov    %eax,%ebx
  8004d3:	89 c7                	mov    %eax,%edi
  8004d5:	89 c6                	mov    %eax,%esi
  8004d7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004d9:	5b                   	pop    %ebx
  8004da:	5e                   	pop    %esi
  8004db:	5f                   	pop    %edi
  8004dc:	5d                   	pop    %ebp
  8004dd:	c3                   	ret    

008004de <sys_cgetc>:

int
sys_cgetc(void)
{
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	57                   	push   %edi
  8004e2:	56                   	push   %esi
  8004e3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8004ee:	89 d1                	mov    %edx,%ecx
  8004f0:	89 d3                	mov    %edx,%ebx
  8004f2:	89 d7                	mov    %edx,%edi
  8004f4:	89 d6                	mov    %edx,%esi
  8004f6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004f8:	5b                   	pop    %ebx
  8004f9:	5e                   	pop    %esi
  8004fa:	5f                   	pop    %edi
  8004fb:	5d                   	pop    %ebp
  8004fc:	c3                   	ret    

008004fd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8004fd:	55                   	push   %ebp
  8004fe:	89 e5                	mov    %esp,%ebp
  800500:	57                   	push   %edi
  800501:	56                   	push   %esi
  800502:	53                   	push   %ebx
  800503:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800506:	b9 00 00 00 00       	mov    $0x0,%ecx
  80050b:	b8 03 00 00 00       	mov    $0x3,%eax
  800510:	8b 55 08             	mov    0x8(%ebp),%edx
  800513:	89 cb                	mov    %ecx,%ebx
  800515:	89 cf                	mov    %ecx,%edi
  800517:	89 ce                	mov    %ecx,%esi
  800519:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80051b:	85 c0                	test   %eax,%eax
  80051d:	7e 28                	jle    800547 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80051f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800523:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80052a:	00 
  80052b:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  800532:	00 
  800533:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80053a:	00 
  80053b:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  800542:	e8 29 10 00 00       	call   801570 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800547:	83 c4 2c             	add    $0x2c,%esp
  80054a:	5b                   	pop    %ebx
  80054b:	5e                   	pop    %esi
  80054c:	5f                   	pop    %edi
  80054d:	5d                   	pop    %ebp
  80054e:	c3                   	ret    

0080054f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80054f:	55                   	push   %ebp
  800550:	89 e5                	mov    %esp,%ebp
  800552:	57                   	push   %edi
  800553:	56                   	push   %esi
  800554:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800555:	ba 00 00 00 00       	mov    $0x0,%edx
  80055a:	b8 02 00 00 00       	mov    $0x2,%eax
  80055f:	89 d1                	mov    %edx,%ecx
  800561:	89 d3                	mov    %edx,%ebx
  800563:	89 d7                	mov    %edx,%edi
  800565:	89 d6                	mov    %edx,%esi
  800567:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800569:	5b                   	pop    %ebx
  80056a:	5e                   	pop    %esi
  80056b:	5f                   	pop    %edi
  80056c:	5d                   	pop    %ebp
  80056d:	c3                   	ret    

0080056e <sys_yield>:

void
sys_yield(void)
{
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
  800571:	57                   	push   %edi
  800572:	56                   	push   %esi
  800573:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800574:	ba 00 00 00 00       	mov    $0x0,%edx
  800579:	b8 0b 00 00 00       	mov    $0xb,%eax
  80057e:	89 d1                	mov    %edx,%ecx
  800580:	89 d3                	mov    %edx,%ebx
  800582:	89 d7                	mov    %edx,%edi
  800584:	89 d6                	mov    %edx,%esi
  800586:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800588:	5b                   	pop    %ebx
  800589:	5e                   	pop    %esi
  80058a:	5f                   	pop    %edi
  80058b:	5d                   	pop    %ebp
  80058c:	c3                   	ret    

0080058d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80058d:	55                   	push   %ebp
  80058e:	89 e5                	mov    %esp,%ebp
  800590:	57                   	push   %edi
  800591:	56                   	push   %esi
  800592:	53                   	push   %ebx
  800593:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800596:	be 00 00 00 00       	mov    $0x0,%esi
  80059b:	b8 04 00 00 00       	mov    $0x4,%eax
  8005a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a9:	89 f7                	mov    %esi,%edi
  8005ab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8005ad:	85 c0                	test   %eax,%eax
  8005af:	7e 28                	jle    8005d9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005b5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8005bc:	00 
  8005bd:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  8005c4:	00 
  8005c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005cc:	00 
  8005cd:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  8005d4:	e8 97 0f 00 00       	call   801570 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005d9:	83 c4 2c             	add    $0x2c,%esp
  8005dc:	5b                   	pop    %ebx
  8005dd:	5e                   	pop    %esi
  8005de:	5f                   	pop    %edi
  8005df:	5d                   	pop    %ebp
  8005e0:	c3                   	ret    

008005e1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005e1:	55                   	push   %ebp
  8005e2:	89 e5                	mov    %esp,%ebp
  8005e4:	57                   	push   %edi
  8005e5:	56                   	push   %esi
  8005e6:	53                   	push   %ebx
  8005e7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8005ef:	8b 75 18             	mov    0x18(%ebp),%esi
  8005f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8005fe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800600:	85 c0                	test   %eax,%eax
  800602:	7e 28                	jle    80062c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800604:	89 44 24 10          	mov    %eax,0x10(%esp)
  800608:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80060f:	00 
  800610:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  800617:	00 
  800618:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80061f:	00 
  800620:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  800627:	e8 44 0f 00 00       	call   801570 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80062c:	83 c4 2c             	add    $0x2c,%esp
  80062f:	5b                   	pop    %ebx
  800630:	5e                   	pop    %esi
  800631:	5f                   	pop    %edi
  800632:	5d                   	pop    %ebp
  800633:	c3                   	ret    

00800634 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800634:	55                   	push   %ebp
  800635:	89 e5                	mov    %esp,%ebp
  800637:	57                   	push   %edi
  800638:	56                   	push   %esi
  800639:	53                   	push   %ebx
  80063a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80063d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800642:	b8 06 00 00 00       	mov    $0x6,%eax
  800647:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80064a:	8b 55 08             	mov    0x8(%ebp),%edx
  80064d:	89 df                	mov    %ebx,%edi
  80064f:	89 de                	mov    %ebx,%esi
  800651:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800653:	85 c0                	test   %eax,%eax
  800655:	7e 28                	jle    80067f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800657:	89 44 24 10          	mov    %eax,0x10(%esp)
  80065b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800662:	00 
  800663:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  80066a:	00 
  80066b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800672:	00 
  800673:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  80067a:	e8 f1 0e 00 00       	call   801570 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80067f:	83 c4 2c             	add    $0x2c,%esp
  800682:	5b                   	pop    %ebx
  800683:	5e                   	pop    %esi
  800684:	5f                   	pop    %edi
  800685:	5d                   	pop    %ebp
  800686:	c3                   	ret    

00800687 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	57                   	push   %edi
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
  80068d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800690:	bb 00 00 00 00       	mov    $0x0,%ebx
  800695:	b8 08 00 00 00       	mov    $0x8,%eax
  80069a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80069d:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a0:	89 df                	mov    %ebx,%edi
  8006a2:	89 de                	mov    %ebx,%esi
  8006a4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006a6:	85 c0                	test   %eax,%eax
  8006a8:	7e 28                	jle    8006d2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ae:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8006b5:	00 
  8006b6:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  8006bd:	00 
  8006be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006c5:	00 
  8006c6:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  8006cd:	e8 9e 0e 00 00       	call   801570 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8006d2:	83 c4 2c             	add    $0x2c,%esp
  8006d5:	5b                   	pop    %ebx
  8006d6:	5e                   	pop    %esi
  8006d7:	5f                   	pop    %edi
  8006d8:	5d                   	pop    %ebp
  8006d9:	c3                   	ret    

008006da <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	57                   	push   %edi
  8006de:	56                   	push   %esi
  8006df:	53                   	push   %ebx
  8006e0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e8:	b8 09 00 00 00       	mov    $0x9,%eax
  8006ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f3:	89 df                	mov    %ebx,%edi
  8006f5:	89 de                	mov    %ebx,%esi
  8006f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	7e 28                	jle    800725 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800701:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800708:	00 
  800709:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  800710:	00 
  800711:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800718:	00 
  800719:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  800720:	e8 4b 0e 00 00       	call   801570 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800725:	83 c4 2c             	add    $0x2c,%esp
  800728:	5b                   	pop    %ebx
  800729:	5e                   	pop    %esi
  80072a:	5f                   	pop    %edi
  80072b:	5d                   	pop    %ebp
  80072c:	c3                   	ret    

0080072d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	57                   	push   %edi
  800731:	56                   	push   %esi
  800732:	53                   	push   %ebx
  800733:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800736:	bb 00 00 00 00       	mov    $0x0,%ebx
  80073b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800740:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
  800746:	89 df                	mov    %ebx,%edi
  800748:	89 de                	mov    %ebx,%esi
  80074a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80074c:	85 c0                	test   %eax,%eax
  80074e:	7e 28                	jle    800778 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800750:	89 44 24 10          	mov    %eax,0x10(%esp)
  800754:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80075b:	00 
  80075c:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  800763:	00 
  800764:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80076b:	00 
  80076c:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  800773:	e8 f8 0d 00 00       	call   801570 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800778:	83 c4 2c             	add    $0x2c,%esp
  80077b:	5b                   	pop    %ebx
  80077c:	5e                   	pop    %esi
  80077d:	5f                   	pop    %edi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	57                   	push   %edi
  800784:	56                   	push   %esi
  800785:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800786:	be 00 00 00 00       	mov    $0x0,%esi
  80078b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800790:	8b 7d 14             	mov    0x14(%ebp),%edi
  800793:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800796:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800799:	8b 55 08             	mov    0x8(%ebp),%edx
  80079c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80079e:	5b                   	pop    %ebx
  80079f:	5e                   	pop    %esi
  8007a0:	5f                   	pop    %edi
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	57                   	push   %edi
  8007a7:	56                   	push   %esi
  8007a8:	53                   	push   %ebx
  8007a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8007b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8007b9:	89 cb                	mov    %ecx,%ebx
  8007bb:	89 cf                	mov    %ecx,%edi
  8007bd:	89 ce                	mov    %ecx,%esi
  8007bf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	7e 28                	jle    8007ed <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007c9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8007d0:	00 
  8007d1:	c7 44 24 08 cf 1f 80 	movl   $0x801fcf,0x8(%esp)
  8007d8:	00 
  8007d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007e0:	00 
  8007e1:	c7 04 24 ec 1f 80 00 	movl   $0x801fec,(%esp)
  8007e8:	e8 83 0d 00 00       	call   801570 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8007ed:	83 c4 2c             	add    $0x2c,%esp
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5f                   	pop    %edi
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    
  8007f5:	00 00                	add    %al,(%eax)
	...

008007f8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	05 00 00 00 30       	add    $0x30000000,%eax
  800803:	c1 e8 0c             	shr    $0xc,%eax
}
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	89 04 24             	mov    %eax,(%esp)
  800814:	e8 df ff ff ff       	call   8007f8 <fd2num>
  800819:	05 20 00 0d 00       	add    $0xd0020,%eax
  80081e:	c1 e0 0c             	shl    $0xc,%eax
}
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80082a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80082f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800831:	89 c2                	mov    %eax,%edx
  800833:	c1 ea 16             	shr    $0x16,%edx
  800836:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80083d:	f6 c2 01             	test   $0x1,%dl
  800840:	74 11                	je     800853 <fd_alloc+0x30>
  800842:	89 c2                	mov    %eax,%edx
  800844:	c1 ea 0c             	shr    $0xc,%edx
  800847:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80084e:	f6 c2 01             	test   $0x1,%dl
  800851:	75 09                	jne    80085c <fd_alloc+0x39>
			*fd_store = fd;
  800853:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
  80085a:	eb 17                	jmp    800873 <fd_alloc+0x50>
  80085c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800861:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800866:	75 c7                	jne    80082f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800868:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80086e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800873:	5b                   	pop    %ebx
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80087c:	83 f8 1f             	cmp    $0x1f,%eax
  80087f:	77 36                	ja     8008b7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800881:	05 00 00 0d 00       	add    $0xd0000,%eax
  800886:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800889:	89 c2                	mov    %eax,%edx
  80088b:	c1 ea 16             	shr    $0x16,%edx
  80088e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800895:	f6 c2 01             	test   $0x1,%dl
  800898:	74 24                	je     8008be <fd_lookup+0x48>
  80089a:	89 c2                	mov    %eax,%edx
  80089c:	c1 ea 0c             	shr    $0xc,%edx
  80089f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8008a6:	f6 c2 01             	test   $0x1,%dl
  8008a9:	74 1a                	je     8008c5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ae:	89 02                	mov    %eax,(%edx)
	return 0;
  8008b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b5:	eb 13                	jmp    8008ca <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008bc:	eb 0c                	jmp    8008ca <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c3:	eb 05                	jmp    8008ca <fd_lookup+0x54>
  8008c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	53                   	push   %ebx
  8008d0:	83 ec 14             	sub    $0x14,%esp
  8008d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8008d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008de:	eb 0e                	jmp    8008ee <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8008e0:	39 08                	cmp    %ecx,(%eax)
  8008e2:	75 09                	jne    8008ed <dev_lookup+0x21>
			*dev = devtab[i];
  8008e4:	89 03                	mov    %eax,(%ebx)
			return 0;
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008eb:	eb 33                	jmp    800920 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008ed:	42                   	inc    %edx
  8008ee:	8b 04 95 78 20 80 00 	mov    0x802078(,%edx,4),%eax
  8008f5:	85 c0                	test   %eax,%eax
  8008f7:	75 e7                	jne    8008e0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8008f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8008fe:	8b 40 48             	mov    0x48(%eax),%eax
  800901:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800905:	89 44 24 04          	mov    %eax,0x4(%esp)
  800909:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800910:	e8 53 0d 00 00       	call   801668 <cprintf>
	*dev = 0;
  800915:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80091b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800920:	83 c4 14             	add    $0x14,%esp
  800923:	5b                   	pop    %ebx
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	83 ec 30             	sub    $0x30,%esp
  80092e:	8b 75 08             	mov    0x8(%ebp),%esi
  800931:	8a 45 0c             	mov    0xc(%ebp),%al
  800934:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800937:	89 34 24             	mov    %esi,(%esp)
  80093a:	e8 b9 fe ff ff       	call   8007f8 <fd2num>
  80093f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800942:	89 54 24 04          	mov    %edx,0x4(%esp)
  800946:	89 04 24             	mov    %eax,(%esp)
  800949:	e8 28 ff ff ff       	call   800876 <fd_lookup>
  80094e:	89 c3                	mov    %eax,%ebx
  800950:	85 c0                	test   %eax,%eax
  800952:	78 05                	js     800959 <fd_close+0x33>
	    || fd != fd2)
  800954:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800957:	74 0d                	je     800966 <fd_close+0x40>
		return (must_exist ? r : 0);
  800959:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80095d:	75 46                	jne    8009a5 <fd_close+0x7f>
  80095f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800964:	eb 3f                	jmp    8009a5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800966:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800969:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096d:	8b 06                	mov    (%esi),%eax
  80096f:	89 04 24             	mov    %eax,(%esp)
  800972:	e8 55 ff ff ff       	call   8008cc <dev_lookup>
  800977:	89 c3                	mov    %eax,%ebx
  800979:	85 c0                	test   %eax,%eax
  80097b:	78 18                	js     800995 <fd_close+0x6f>
		if (dev->dev_close)
  80097d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800980:	8b 40 10             	mov    0x10(%eax),%eax
  800983:	85 c0                	test   %eax,%eax
  800985:	74 09                	je     800990 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800987:	89 34 24             	mov    %esi,(%esp)
  80098a:	ff d0                	call   *%eax
  80098c:	89 c3                	mov    %eax,%ebx
  80098e:	eb 05                	jmp    800995 <fd_close+0x6f>
		else
			r = 0;
  800990:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800995:	89 74 24 04          	mov    %esi,0x4(%esp)
  800999:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009a0:	e8 8f fc ff ff       	call   800634 <sys_page_unmap>
	return r;
}
  8009a5:	89 d8                	mov    %ebx,%eax
  8009a7:	83 c4 30             	add    $0x30,%esp
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	89 04 24             	mov    %eax,(%esp)
  8009c1:	e8 b0 fe ff ff       	call   800876 <fd_lookup>
  8009c6:	85 c0                	test   %eax,%eax
  8009c8:	78 13                	js     8009dd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8009ca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8009d1:	00 
  8009d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d5:	89 04 24             	mov    %eax,(%esp)
  8009d8:	e8 49 ff ff ff       	call   800926 <fd_close>
}
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <close_all>:

void
close_all(void)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	53                   	push   %ebx
  8009e3:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8009e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8009eb:	89 1c 24             	mov    %ebx,(%esp)
  8009ee:	e8 bb ff ff ff       	call   8009ae <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8009f3:	43                   	inc    %ebx
  8009f4:	83 fb 20             	cmp    $0x20,%ebx
  8009f7:	75 f2                	jne    8009eb <close_all+0xc>
		close(i);
}
  8009f9:	83 c4 14             	add    $0x14,%esp
  8009fc:	5b                   	pop    %ebx
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	57                   	push   %edi
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	83 ec 4c             	sub    $0x4c,%esp
  800a08:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800a0b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	89 04 24             	mov    %eax,(%esp)
  800a18:	e8 59 fe ff ff       	call   800876 <fd_lookup>
  800a1d:	89 c3                	mov    %eax,%ebx
  800a1f:	85 c0                	test   %eax,%eax
  800a21:	0f 88 e1 00 00 00    	js     800b08 <dup+0x109>
		return r;
	close(newfdnum);
  800a27:	89 3c 24             	mov    %edi,(%esp)
  800a2a:	e8 7f ff ff ff       	call   8009ae <close>

	newfd = INDEX2FD(newfdnum);
  800a2f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800a35:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800a38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a3b:	89 04 24             	mov    %eax,(%esp)
  800a3e:	e8 c5 fd ff ff       	call   800808 <fd2data>
  800a43:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800a45:	89 34 24             	mov    %esi,(%esp)
  800a48:	e8 bb fd ff ff       	call   800808 <fd2data>
  800a4d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800a50:	89 d8                	mov    %ebx,%eax
  800a52:	c1 e8 16             	shr    $0x16,%eax
  800a55:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a5c:	a8 01                	test   $0x1,%al
  800a5e:	74 46                	je     800aa6 <dup+0xa7>
  800a60:	89 d8                	mov    %ebx,%eax
  800a62:	c1 e8 0c             	shr    $0xc,%eax
  800a65:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a6c:	f6 c2 01             	test   $0x1,%dl
  800a6f:	74 35                	je     800aa6 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a71:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a78:	25 07 0e 00 00       	and    $0xe07,%eax
  800a7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a81:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800a84:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a88:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a8f:	00 
  800a90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a9b:	e8 41 fb ff ff       	call   8005e1 <sys_page_map>
  800aa0:	89 c3                	mov    %eax,%ebx
  800aa2:	85 c0                	test   %eax,%eax
  800aa4:	78 3b                	js     800ae1 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800aa6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800aa9:	89 c2                	mov    %eax,%edx
  800aab:	c1 ea 0c             	shr    $0xc,%edx
  800aae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ab5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800abb:	89 54 24 10          	mov    %edx,0x10(%esp)
  800abf:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ac3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800aca:	00 
  800acb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800acf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ad6:	e8 06 fb ff ff       	call   8005e1 <sys_page_map>
  800adb:	89 c3                	mov    %eax,%ebx
  800add:	85 c0                	test   %eax,%eax
  800adf:	79 25                	jns    800b06 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800ae1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ae5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800aec:	e8 43 fb ff ff       	call   800634 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800af1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800af4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800aff:	e8 30 fb ff ff       	call   800634 <sys_page_unmap>
	return r;
  800b04:	eb 02                	jmp    800b08 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800b06:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800b08:	89 d8                	mov    %ebx,%eax
  800b0a:	83 c4 4c             	add    $0x4c,%esp
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	53                   	push   %ebx
  800b16:	83 ec 24             	sub    $0x24,%esp
  800b19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b1c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b23:	89 1c 24             	mov    %ebx,(%esp)
  800b26:	e8 4b fd ff ff       	call   800876 <fd_lookup>
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	78 6d                	js     800b9c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b39:	8b 00                	mov    (%eax),%eax
  800b3b:	89 04 24             	mov    %eax,(%esp)
  800b3e:	e8 89 fd ff ff       	call   8008cc <dev_lookup>
  800b43:	85 c0                	test   %eax,%eax
  800b45:	78 55                	js     800b9c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800b47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b4a:	8b 50 08             	mov    0x8(%eax),%edx
  800b4d:	83 e2 03             	and    $0x3,%edx
  800b50:	83 fa 01             	cmp    $0x1,%edx
  800b53:	75 23                	jne    800b78 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800b55:	a1 04 40 80 00       	mov    0x804004,%eax
  800b5a:	8b 40 48             	mov    0x48(%eax),%eax
  800b5d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b65:	c7 04 24 3d 20 80 00 	movl   $0x80203d,(%esp)
  800b6c:	e8 f7 0a 00 00       	call   801668 <cprintf>
		return -E_INVAL;
  800b71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b76:	eb 24                	jmp    800b9c <read+0x8a>
	}
	if (!dev->dev_read)
  800b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b7b:	8b 52 08             	mov    0x8(%edx),%edx
  800b7e:	85 d2                	test   %edx,%edx
  800b80:	74 15                	je     800b97 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800b82:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b85:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b90:	89 04 24             	mov    %eax,(%esp)
  800b93:	ff d2                	call   *%edx
  800b95:	eb 05                	jmp    800b9c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800b97:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800b9c:	83 c4 24             	add    $0x24,%esp
  800b9f:	5b                   	pop    %ebx
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 1c             	sub    $0x1c,%esp
  800bab:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bae:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800bb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb6:	eb 23                	jmp    800bdb <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800bb8:	89 f0                	mov    %esi,%eax
  800bba:	29 d8                	sub    %ebx,%eax
  800bbc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc3:	01 d8                	add    %ebx,%eax
  800bc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc9:	89 3c 24             	mov    %edi,(%esp)
  800bcc:	e8 41 ff ff ff       	call   800b12 <read>
		if (m < 0)
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	78 10                	js     800be5 <readn+0x43>
			return m;
		if (m == 0)
  800bd5:	85 c0                	test   %eax,%eax
  800bd7:	74 0a                	je     800be3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800bd9:	01 c3                	add    %eax,%ebx
  800bdb:	39 f3                	cmp    %esi,%ebx
  800bdd:	72 d9                	jb     800bb8 <readn+0x16>
  800bdf:	89 d8                	mov    %ebx,%eax
  800be1:	eb 02                	jmp    800be5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800be3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800be5:	83 c4 1c             	add    $0x1c,%esp
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 24             	sub    $0x24,%esp
  800bf4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bf7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bfe:	89 1c 24             	mov    %ebx,(%esp)
  800c01:	e8 70 fc ff ff       	call   800876 <fd_lookup>
  800c06:	85 c0                	test   %eax,%eax
  800c08:	78 68                	js     800c72 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c14:	8b 00                	mov    (%eax),%eax
  800c16:	89 04 24             	mov    %eax,(%esp)
  800c19:	e8 ae fc ff ff       	call   8008cc <dev_lookup>
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	78 50                	js     800c72 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c25:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c29:	75 23                	jne    800c4e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800c2b:	a1 04 40 80 00       	mov    0x804004,%eax
  800c30:	8b 40 48             	mov    0x48(%eax),%eax
  800c33:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c3b:	c7 04 24 59 20 80 00 	movl   $0x802059,(%esp)
  800c42:	e8 21 0a 00 00       	call   801668 <cprintf>
		return -E_INVAL;
  800c47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c4c:	eb 24                	jmp    800c72 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800c4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c51:	8b 52 0c             	mov    0xc(%edx),%edx
  800c54:	85 d2                	test   %edx,%edx
  800c56:	74 15                	je     800c6d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800c58:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c5b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c62:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c66:	89 04 24             	mov    %eax,(%esp)
  800c69:	ff d2                	call   *%edx
  800c6b:	eb 05                	jmp    800c72 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800c6d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800c72:	83 c4 24             	add    $0x24,%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <seek>:

int
seek(int fdnum, off_t offset)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c7e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800c81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c85:	8b 45 08             	mov    0x8(%ebp),%eax
  800c88:	89 04 24             	mov    %eax,(%esp)
  800c8b:	e8 e6 fb ff ff       	call   800876 <fd_lookup>
  800c90:	85 c0                	test   %eax,%eax
  800c92:	78 0e                	js     800ca2 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800c94:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800c9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca2:	c9                   	leave  
  800ca3:	c3                   	ret    

00800ca4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 24             	sub    $0x24,%esp
  800cab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800cae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb5:	89 1c 24             	mov    %ebx,(%esp)
  800cb8:	e8 b9 fb ff ff       	call   800876 <fd_lookup>
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	78 61                	js     800d22 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ccb:	8b 00                	mov    (%eax),%eax
  800ccd:	89 04 24             	mov    %eax,(%esp)
  800cd0:	e8 f7 fb ff ff       	call   8008cc <dev_lookup>
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	78 49                	js     800d22 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cdc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ce0:	75 23                	jne    800d05 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800ce2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800ce7:	8b 40 48             	mov    0x48(%eax),%eax
  800cea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800cee:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf2:	c7 04 24 1c 20 80 00 	movl   $0x80201c,(%esp)
  800cf9:	e8 6a 09 00 00       	call   801668 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800cfe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d03:	eb 1d                	jmp    800d22 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800d05:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d08:	8b 52 18             	mov    0x18(%edx),%edx
  800d0b:	85 d2                	test   %edx,%edx
  800d0d:	74 0e                	je     800d1d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800d0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d12:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d16:	89 04 24             	mov    %eax,(%esp)
  800d19:	ff d2                	call   *%edx
  800d1b:	eb 05                	jmp    800d22 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800d1d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800d22:	83 c4 24             	add    $0x24,%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 24             	sub    $0x24,%esp
  800d2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d32:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d35:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3c:	89 04 24             	mov    %eax,(%esp)
  800d3f:	e8 32 fb ff ff       	call   800876 <fd_lookup>
  800d44:	85 c0                	test   %eax,%eax
  800d46:	78 52                	js     800d9a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d52:	8b 00                	mov    (%eax),%eax
  800d54:	89 04 24             	mov    %eax,(%esp)
  800d57:	e8 70 fb ff ff       	call   8008cc <dev_lookup>
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	78 3a                	js     800d9a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d63:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800d67:	74 2c                	je     800d95 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800d69:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800d6c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800d73:	00 00 00 
	stat->st_isdir = 0;
  800d76:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800d7d:	00 00 00 
	stat->st_dev = dev;
  800d80:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800d86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d8d:	89 14 24             	mov    %edx,(%esp)
  800d90:	ff 50 14             	call   *0x14(%eax)
  800d93:	eb 05                	jmp    800d9a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800d95:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800d9a:	83 c4 24             	add    $0x24,%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
  800da5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800da8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800daf:	00 
  800db0:	8b 45 08             	mov    0x8(%ebp),%eax
  800db3:	89 04 24             	mov    %eax,(%esp)
  800db6:	e8 fe 01 00 00       	call   800fb9 <open>
  800dbb:	89 c3                	mov    %eax,%ebx
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	78 1b                	js     800ddc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800dc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc8:	89 1c 24             	mov    %ebx,(%esp)
  800dcb:	e8 58 ff ff ff       	call   800d28 <fstat>
  800dd0:	89 c6                	mov    %eax,%esi
	close(fd);
  800dd2:	89 1c 24             	mov    %ebx,(%esp)
  800dd5:	e8 d4 fb ff ff       	call   8009ae <close>
	return r;
  800dda:	89 f3                	mov    %esi,%ebx
}
  800ddc:	89 d8                	mov    %ebx,%eax
  800dde:	83 c4 10             	add    $0x10,%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    
  800de5:	00 00                	add    %al,(%eax)
	...

00800de8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
  800ded:	83 ec 10             	sub    $0x10,%esp
  800df0:	89 c3                	mov    %eax,%ebx
  800df2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800df4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800dfb:	75 11                	jne    800e0e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800dfd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800e04:	e8 c8 0e 00 00       	call   801cd1 <ipc_find_env>
  800e09:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800e0e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800e15:	00 
  800e16:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800e1d:	00 
  800e1e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e22:	a1 00 40 80 00       	mov    0x804000,%eax
  800e27:	89 04 24             	mov    %eax,(%esp)
  800e2a:	e8 38 0e 00 00       	call   801c67 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800e2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e36:	00 
  800e37:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e42:	e8 b9 0d 00 00       	call   801c00 <ipc_recv>
}
  800e47:	83 c4 10             	add    $0x10,%esp
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800e54:	8b 45 08             	mov    0x8(%ebp),%eax
  800e57:	8b 40 0c             	mov    0xc(%eax),%eax
  800e5a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800e5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e62:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800e67:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6c:	b8 02 00 00 00       	mov    $0x2,%eax
  800e71:	e8 72 ff ff ff       	call   800de8 <fsipc>
}
  800e76:	c9                   	leave  
  800e77:	c3                   	ret    

00800e78 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800e7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e81:	8b 40 0c             	mov    0xc(%eax),%eax
  800e84:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800e89:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e93:	e8 50 ff ff ff       	call   800de8 <fsipc>
}
  800e98:	c9                   	leave  
  800e99:	c3                   	ret    

00800e9a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	53                   	push   %ebx
  800e9e:	83 ec 14             	sub    $0x14,%esp
  800ea1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800ea4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea7:	8b 40 0c             	mov    0xc(%eax),%eax
  800eaa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800eaf:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb4:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb9:	e8 2a ff ff ff       	call   800de8 <fsipc>
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	78 2b                	js     800eed <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ec2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ec9:	00 
  800eca:	89 1c 24             	mov    %ebx,(%esp)
  800ecd:	e8 c9 f2 ff ff       	call   80019b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ed2:	a1 80 50 80 00       	mov    0x805080,%eax
  800ed7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800edd:	a1 84 50 80 00       	mov    0x805084,%eax
  800ee2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ee8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eed:	83 c4 14             	add    $0x14,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800ef9:	c7 44 24 08 88 20 80 	movl   $0x802088,0x8(%esp)
  800f00:	00 
  800f01:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800f08:	00 
  800f09:	c7 04 24 a6 20 80 00 	movl   $0x8020a6,(%esp)
  800f10:	e8 5b 06 00 00       	call   801570 <_panic>

00800f15 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	56                   	push   %esi
  800f19:	53                   	push   %ebx
  800f1a:	83 ec 10             	sub    $0x10,%esp
  800f1d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800f20:	8b 45 08             	mov    0x8(%ebp),%eax
  800f23:	8b 40 0c             	mov    0xc(%eax),%eax
  800f26:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800f2b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800f31:	ba 00 00 00 00       	mov    $0x0,%edx
  800f36:	b8 03 00 00 00       	mov    $0x3,%eax
  800f3b:	e8 a8 fe ff ff       	call   800de8 <fsipc>
  800f40:	89 c3                	mov    %eax,%ebx
  800f42:	85 c0                	test   %eax,%eax
  800f44:	78 6a                	js     800fb0 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800f46:	39 c6                	cmp    %eax,%esi
  800f48:	73 24                	jae    800f6e <devfile_read+0x59>
  800f4a:	c7 44 24 0c b1 20 80 	movl   $0x8020b1,0xc(%esp)
  800f51:	00 
  800f52:	c7 44 24 08 b8 20 80 	movl   $0x8020b8,0x8(%esp)
  800f59:	00 
  800f5a:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800f61:	00 
  800f62:	c7 04 24 a6 20 80 00 	movl   $0x8020a6,(%esp)
  800f69:	e8 02 06 00 00       	call   801570 <_panic>
	assert(r <= PGSIZE);
  800f6e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800f73:	7e 24                	jle    800f99 <devfile_read+0x84>
  800f75:	c7 44 24 0c cd 20 80 	movl   $0x8020cd,0xc(%esp)
  800f7c:	00 
  800f7d:	c7 44 24 08 b8 20 80 	movl   $0x8020b8,0x8(%esp)
  800f84:	00 
  800f85:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800f8c:	00 
  800f8d:	c7 04 24 a6 20 80 00 	movl   $0x8020a6,(%esp)
  800f94:	e8 d7 05 00 00       	call   801570 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800f99:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f9d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800fa4:	00 
  800fa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa8:	89 04 24             	mov    %eax,(%esp)
  800fab:	e8 64 f3 ff ff       	call   800314 <memmove>
	return r;
}
  800fb0:	89 d8                	mov    %ebx,%eax
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    

00800fb9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	56                   	push   %esi
  800fbd:	53                   	push   %ebx
  800fbe:	83 ec 20             	sub    $0x20,%esp
  800fc1:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800fc4:	89 34 24             	mov    %esi,(%esp)
  800fc7:	e8 9c f1 ff ff       	call   800168 <strlen>
  800fcc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800fd1:	7f 60                	jg     801033 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800fd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd6:	89 04 24             	mov    %eax,(%esp)
  800fd9:	e8 45 f8 ff ff       	call   800823 <fd_alloc>
  800fde:	89 c3                	mov    %eax,%ebx
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	78 54                	js     801038 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800fe4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fe8:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800fef:	e8 a7 f1 ff ff       	call   80019b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ffc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fff:	b8 01 00 00 00       	mov    $0x1,%eax
  801004:	e8 df fd ff ff       	call   800de8 <fsipc>
  801009:	89 c3                	mov    %eax,%ebx
  80100b:	85 c0                	test   %eax,%eax
  80100d:	79 15                	jns    801024 <open+0x6b>
		fd_close(fd, 0);
  80100f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801016:	00 
  801017:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101a:	89 04 24             	mov    %eax,(%esp)
  80101d:	e8 04 f9 ff ff       	call   800926 <fd_close>
		return r;
  801022:	eb 14                	jmp    801038 <open+0x7f>
	}

	return fd2num(fd);
  801024:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801027:	89 04 24             	mov    %eax,(%esp)
  80102a:	e8 c9 f7 ff ff       	call   8007f8 <fd2num>
  80102f:	89 c3                	mov    %eax,%ebx
  801031:	eb 05                	jmp    801038 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801033:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801038:	89 d8                	mov    %ebx,%eax
  80103a:	83 c4 20             	add    $0x20,%esp
  80103d:	5b                   	pop    %ebx
  80103e:	5e                   	pop    %esi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    

00801041 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801047:	ba 00 00 00 00       	mov    $0x0,%edx
  80104c:	b8 08 00 00 00       	mov    $0x8,%eax
  801051:	e8 92 fd ff ff       	call   800de8 <fsipc>
}
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
  80105d:	83 ec 10             	sub    $0x10,%esp
  801060:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801063:	8b 45 08             	mov    0x8(%ebp),%eax
  801066:	89 04 24             	mov    %eax,(%esp)
  801069:	e8 9a f7 ff ff       	call   800808 <fd2data>
  80106e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801070:	c7 44 24 04 d9 20 80 	movl   $0x8020d9,0x4(%esp)
  801077:	00 
  801078:	89 34 24             	mov    %esi,(%esp)
  80107b:	e8 1b f1 ff ff       	call   80019b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801080:	8b 43 04             	mov    0x4(%ebx),%eax
  801083:	2b 03                	sub    (%ebx),%eax
  801085:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80108b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801092:	00 00 00 
	stat->st_dev = &devpipe;
  801095:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80109c:	30 80 00 
	return 0;
}
  80109f:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	5b                   	pop    %ebx
  8010a8:	5e                   	pop    %esi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	53                   	push   %ebx
  8010af:	83 ec 14             	sub    $0x14,%esp
  8010b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c0:	e8 6f f5 ff ff       	call   800634 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010c5:	89 1c 24             	mov    %ebx,(%esp)
  8010c8:	e8 3b f7 ff ff       	call   800808 <fd2data>
  8010cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d8:	e8 57 f5 ff ff       	call   800634 <sys_page_unmap>
}
  8010dd:	83 c4 14             	add    $0x14,%esp
  8010e0:	5b                   	pop    %ebx
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	53                   	push   %ebx
  8010e9:	83 ec 2c             	sub    $0x2c,%esp
  8010ec:	89 c7                	mov    %eax,%edi
  8010ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8010f6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8010f9:	89 3c 24             	mov    %edi,(%esp)
  8010fc:	e8 17 0c 00 00       	call   801d18 <pageref>
  801101:	89 c6                	mov    %eax,%esi
  801103:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801106:	89 04 24             	mov    %eax,(%esp)
  801109:	e8 0a 0c 00 00       	call   801d18 <pageref>
  80110e:	39 c6                	cmp    %eax,%esi
  801110:	0f 94 c0             	sete   %al
  801113:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801116:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80111c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80111f:	39 cb                	cmp    %ecx,%ebx
  801121:	75 08                	jne    80112b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801123:	83 c4 2c             	add    $0x2c,%esp
  801126:	5b                   	pop    %ebx
  801127:	5e                   	pop    %esi
  801128:	5f                   	pop    %edi
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80112b:	83 f8 01             	cmp    $0x1,%eax
  80112e:	75 c1                	jne    8010f1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801130:	8b 42 58             	mov    0x58(%edx),%eax
  801133:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80113a:	00 
  80113b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80113f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801143:	c7 04 24 e0 20 80 00 	movl   $0x8020e0,(%esp)
  80114a:	e8 19 05 00 00       	call   801668 <cprintf>
  80114f:	eb a0                	jmp    8010f1 <_pipeisclosed+0xe>

00801151 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	57                   	push   %edi
  801155:	56                   	push   %esi
  801156:	53                   	push   %ebx
  801157:	83 ec 1c             	sub    $0x1c,%esp
  80115a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80115d:	89 34 24             	mov    %esi,(%esp)
  801160:	e8 a3 f6 ff ff       	call   800808 <fd2data>
  801165:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801167:	bf 00 00 00 00       	mov    $0x0,%edi
  80116c:	eb 3c                	jmp    8011aa <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80116e:	89 da                	mov    %ebx,%edx
  801170:	89 f0                	mov    %esi,%eax
  801172:	e8 6c ff ff ff       	call   8010e3 <_pipeisclosed>
  801177:	85 c0                	test   %eax,%eax
  801179:	75 38                	jne    8011b3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80117b:	e8 ee f3 ff ff       	call   80056e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801180:	8b 43 04             	mov    0x4(%ebx),%eax
  801183:	8b 13                	mov    (%ebx),%edx
  801185:	83 c2 20             	add    $0x20,%edx
  801188:	39 d0                	cmp    %edx,%eax
  80118a:	73 e2                	jae    80116e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80118c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801192:	89 c2                	mov    %eax,%edx
  801194:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80119a:	79 05                	jns    8011a1 <devpipe_write+0x50>
  80119c:	4a                   	dec    %edx
  80119d:	83 ca e0             	or     $0xffffffe0,%edx
  8011a0:	42                   	inc    %edx
  8011a1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8011a5:	40                   	inc    %eax
  8011a6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011a9:	47                   	inc    %edi
  8011aa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011ad:	75 d1                	jne    801180 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011af:	89 f8                	mov    %edi,%eax
  8011b1:	eb 05                	jmp    8011b8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011b3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011b8:	83 c4 1c             	add    $0x1c,%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5e                   	pop    %esi
  8011bd:	5f                   	pop    %edi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	57                   	push   %edi
  8011c4:	56                   	push   %esi
  8011c5:	53                   	push   %ebx
  8011c6:	83 ec 1c             	sub    $0x1c,%esp
  8011c9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011cc:	89 3c 24             	mov    %edi,(%esp)
  8011cf:	e8 34 f6 ff ff       	call   800808 <fd2data>
  8011d4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011d6:	be 00 00 00 00       	mov    $0x0,%esi
  8011db:	eb 3a                	jmp    801217 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011dd:	85 f6                	test   %esi,%esi
  8011df:	74 04                	je     8011e5 <devpipe_read+0x25>
				return i;
  8011e1:	89 f0                	mov    %esi,%eax
  8011e3:	eb 40                	jmp    801225 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011e5:	89 da                	mov    %ebx,%edx
  8011e7:	89 f8                	mov    %edi,%eax
  8011e9:	e8 f5 fe ff ff       	call   8010e3 <_pipeisclosed>
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	75 2e                	jne    801220 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011f2:	e8 77 f3 ff ff       	call   80056e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011f7:	8b 03                	mov    (%ebx),%eax
  8011f9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8011fc:	74 df                	je     8011dd <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011fe:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801203:	79 05                	jns    80120a <devpipe_read+0x4a>
  801205:	48                   	dec    %eax
  801206:	83 c8 e0             	or     $0xffffffe0,%eax
  801209:	40                   	inc    %eax
  80120a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80120e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801211:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801214:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801216:	46                   	inc    %esi
  801217:	3b 75 10             	cmp    0x10(%ebp),%esi
  80121a:	75 db                	jne    8011f7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80121c:	89 f0                	mov    %esi,%eax
  80121e:	eb 05                	jmp    801225 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801220:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801225:	83 c4 1c             	add    $0x1c,%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	57                   	push   %edi
  801231:	56                   	push   %esi
  801232:	53                   	push   %ebx
  801233:	83 ec 3c             	sub    $0x3c,%esp
  801236:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801239:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80123c:	89 04 24             	mov    %eax,(%esp)
  80123f:	e8 df f5 ff ff       	call   800823 <fd_alloc>
  801244:	89 c3                	mov    %eax,%ebx
  801246:	85 c0                	test   %eax,%eax
  801248:	0f 88 45 01 00 00    	js     801393 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80124e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801255:	00 
  801256:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801264:	e8 24 f3 ff ff       	call   80058d <sys_page_alloc>
  801269:	89 c3                	mov    %eax,%ebx
  80126b:	85 c0                	test   %eax,%eax
  80126d:	0f 88 20 01 00 00    	js     801393 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801273:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801276:	89 04 24             	mov    %eax,(%esp)
  801279:	e8 a5 f5 ff ff       	call   800823 <fd_alloc>
  80127e:	89 c3                	mov    %eax,%ebx
  801280:	85 c0                	test   %eax,%eax
  801282:	0f 88 f8 00 00 00    	js     801380 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801288:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80128f:	00 
  801290:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801293:	89 44 24 04          	mov    %eax,0x4(%esp)
  801297:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80129e:	e8 ea f2 ff ff       	call   80058d <sys_page_alloc>
  8012a3:	89 c3                	mov    %eax,%ebx
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	0f 88 d3 00 00 00    	js     801380 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8012ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012b0:	89 04 24             	mov    %eax,(%esp)
  8012b3:	e8 50 f5 ff ff       	call   800808 <fd2data>
  8012b8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012ba:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8012c1:	00 
  8012c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012cd:	e8 bb f2 ff ff       	call   80058d <sys_page_alloc>
  8012d2:	89 c3                	mov    %eax,%ebx
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	0f 88 91 00 00 00    	js     80136d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012df:	89 04 24             	mov    %eax,(%esp)
  8012e2:	e8 21 f5 ff ff       	call   800808 <fd2data>
  8012e7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8012ee:	00 
  8012ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012fa:	00 
  8012fb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801306:	e8 d6 f2 ff ff       	call   8005e1 <sys_page_map>
  80130b:	89 c3                	mov    %eax,%ebx
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 4c                	js     80135d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801311:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801317:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80131a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80131c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80131f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801326:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80132c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80132f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801331:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801334:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80133b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80133e:	89 04 24             	mov    %eax,(%esp)
  801341:	e8 b2 f4 ff ff       	call   8007f8 <fd2num>
  801346:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801348:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80134b:	89 04 24             	mov    %eax,(%esp)
  80134e:	e8 a5 f4 ff ff       	call   8007f8 <fd2num>
  801353:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801356:	bb 00 00 00 00       	mov    $0x0,%ebx
  80135b:	eb 36                	jmp    801393 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80135d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801361:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801368:	e8 c7 f2 ff ff       	call   800634 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80136d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801370:	89 44 24 04          	mov    %eax,0x4(%esp)
  801374:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80137b:	e8 b4 f2 ff ff       	call   800634 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801380:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801383:	89 44 24 04          	mov    %eax,0x4(%esp)
  801387:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80138e:	e8 a1 f2 ff ff       	call   800634 <sys_page_unmap>
    err:
	return r;
}
  801393:	89 d8                	mov    %ebx,%eax
  801395:	83 c4 3c             	add    $0x3c,%esp
  801398:	5b                   	pop    %ebx
  801399:	5e                   	pop    %esi
  80139a:	5f                   	pop    %edi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    

0080139d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ad:	89 04 24             	mov    %eax,(%esp)
  8013b0:	e8 c1 f4 ff ff       	call   800876 <fd_lookup>
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	78 15                	js     8013ce <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8013b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013bc:	89 04 24             	mov    %eax,(%esp)
  8013bf:	e8 44 f4 ff ff       	call   800808 <fd2data>
	return _pipeisclosed(fd, p);
  8013c4:	89 c2                	mov    %eax,%edx
  8013c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c9:	e8 15 fd ff ff       	call   8010e3 <_pipeisclosed>
}
  8013ce:	c9                   	leave  
  8013cf:	c3                   	ret    

008013d0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8013e0:	c7 44 24 04 f8 20 80 	movl   $0x8020f8,0x4(%esp)
  8013e7:	00 
  8013e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013eb:	89 04 24             	mov    %eax,(%esp)
  8013ee:	e8 a8 ed ff ff       	call   80019b <strcpy>
	return 0;
}
  8013f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    

008013fa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	57                   	push   %edi
  8013fe:	56                   	push   %esi
  8013ff:	53                   	push   %ebx
  801400:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801406:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80140b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801411:	eb 30                	jmp    801443 <devcons_write+0x49>
		m = n - tot;
  801413:	8b 75 10             	mov    0x10(%ebp),%esi
  801416:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801418:	83 fe 7f             	cmp    $0x7f,%esi
  80141b:	76 05                	jbe    801422 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80141d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801422:	89 74 24 08          	mov    %esi,0x8(%esp)
  801426:	03 45 0c             	add    0xc(%ebp),%eax
  801429:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142d:	89 3c 24             	mov    %edi,(%esp)
  801430:	e8 df ee ff ff       	call   800314 <memmove>
		sys_cputs(buf, m);
  801435:	89 74 24 04          	mov    %esi,0x4(%esp)
  801439:	89 3c 24             	mov    %edi,(%esp)
  80143c:	e8 7f f0 ff ff       	call   8004c0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801441:	01 f3                	add    %esi,%ebx
  801443:	89 d8                	mov    %ebx,%eax
  801445:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801448:	72 c9                	jb     801413 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80144a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801450:	5b                   	pop    %ebx
  801451:	5e                   	pop    %esi
  801452:	5f                   	pop    %edi
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    

00801455 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80145b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80145f:	75 07                	jne    801468 <devcons_read+0x13>
  801461:	eb 25                	jmp    801488 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801463:	e8 06 f1 ff ff       	call   80056e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801468:	e8 71 f0 ff ff       	call   8004de <sys_cgetc>
  80146d:	85 c0                	test   %eax,%eax
  80146f:	74 f2                	je     801463 <devcons_read+0xe>
  801471:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801473:	85 c0                	test   %eax,%eax
  801475:	78 1d                	js     801494 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801477:	83 f8 04             	cmp    $0x4,%eax
  80147a:	74 13                	je     80148f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80147c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147f:	88 10                	mov    %dl,(%eax)
	return 1;
  801481:	b8 01 00 00 00       	mov    $0x1,%eax
  801486:	eb 0c                	jmp    801494 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801488:	b8 00 00 00 00       	mov    $0x0,%eax
  80148d:	eb 05                	jmp    801494 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80148f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801494:	c9                   	leave  
  801495:	c3                   	ret    

00801496 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80149c:	8b 45 08             	mov    0x8(%ebp),%eax
  80149f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014a9:	00 
  8014aa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014ad:	89 04 24             	mov    %eax,(%esp)
  8014b0:	e8 0b f0 ff ff       	call   8004c0 <sys_cputs>
}
  8014b5:	c9                   	leave  
  8014b6:	c3                   	ret    

008014b7 <getchar>:

int
getchar(void)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8014bd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8014c4:	00 
  8014c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d3:	e8 3a f6 ff ff       	call   800b12 <read>
	if (r < 0)
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	78 0f                	js     8014eb <getchar+0x34>
		return r;
	if (r < 1)
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	7e 06                	jle    8014e6 <getchar+0x2f>
		return -E_EOF;
	return c;
  8014e0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014e4:	eb 05                	jmp    8014eb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014e6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    

008014ed <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fd:	89 04 24             	mov    %eax,(%esp)
  801500:	e8 71 f3 ff ff       	call   800876 <fd_lookup>
  801505:	85 c0                	test   %eax,%eax
  801507:	78 11                	js     80151a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801509:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801512:	39 10                	cmp    %edx,(%eax)
  801514:	0f 94 c0             	sete   %al
  801517:	0f b6 c0             	movzbl %al,%eax
}
  80151a:	c9                   	leave  
  80151b:	c3                   	ret    

0080151c <opencons>:

int
opencons(void)
{
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801522:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801525:	89 04 24             	mov    %eax,(%esp)
  801528:	e8 f6 f2 ff ff       	call   800823 <fd_alloc>
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 3c                	js     80156d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801531:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801538:	00 
  801539:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801540:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801547:	e8 41 f0 ff ff       	call   80058d <sys_page_alloc>
  80154c:	85 c0                	test   %eax,%eax
  80154e:	78 1d                	js     80156d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801550:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801556:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801559:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80155b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801565:	89 04 24             	mov    %eax,(%esp)
  801568:	e8 8b f2 ff ff       	call   8007f8 <fd2num>
}
  80156d:	c9                   	leave  
  80156e:	c3                   	ret    
	...

00801570 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	56                   	push   %esi
  801574:	53                   	push   %ebx
  801575:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801578:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80157b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801581:	e8 c9 ef ff ff       	call   80054f <sys_getenvid>
  801586:	8b 55 0c             	mov    0xc(%ebp),%edx
  801589:	89 54 24 10          	mov    %edx,0x10(%esp)
  80158d:	8b 55 08             	mov    0x8(%ebp),%edx
  801590:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801594:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801598:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159c:	c7 04 24 04 21 80 00 	movl   $0x802104,(%esp)
  8015a3:	e8 c0 00 00 00       	call   801668 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8015af:	89 04 24             	mov    %eax,(%esp)
  8015b2:	e8 50 00 00 00       	call   801607 <vcprintf>
	cprintf("\n");
  8015b7:	c7 04 24 f1 20 80 00 	movl   $0x8020f1,(%esp)
  8015be:	e8 a5 00 00 00       	call   801668 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015c3:	cc                   	int3   
  8015c4:	eb fd                	jmp    8015c3 <_panic+0x53>
	...

008015c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	53                   	push   %ebx
  8015cc:	83 ec 14             	sub    $0x14,%esp
  8015cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8015d2:	8b 03                	mov    (%ebx),%eax
  8015d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8015d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8015db:	40                   	inc    %eax
  8015dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8015de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8015e3:	75 19                	jne    8015fe <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8015e5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8015ec:	00 
  8015ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8015f0:	89 04 24             	mov    %eax,(%esp)
  8015f3:	e8 c8 ee ff ff       	call   8004c0 <sys_cputs>
		b->idx = 0;
  8015f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8015fe:	ff 43 04             	incl   0x4(%ebx)
}
  801601:	83 c4 14             	add    $0x14,%esp
  801604:	5b                   	pop    %ebx
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    

00801607 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801610:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801617:	00 00 00 
	b.cnt = 0;
  80161a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801621:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801624:	8b 45 0c             	mov    0xc(%ebp),%eax
  801627:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80162b:	8b 45 08             	mov    0x8(%ebp),%eax
  80162e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801632:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801638:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163c:	c7 04 24 c8 15 80 00 	movl   $0x8015c8,(%esp)
  801643:	e8 82 01 00 00       	call   8017ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801648:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80164e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801652:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801658:	89 04 24             	mov    %eax,(%esp)
  80165b:	e8 60 ee ff ff       	call   8004c0 <sys_cputs>

	return b.cnt;
}
  801660:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80166e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801671:	89 44 24 04          	mov    %eax,0x4(%esp)
  801675:	8b 45 08             	mov    0x8(%ebp),%eax
  801678:	89 04 24             	mov    %eax,(%esp)
  80167b:	e8 87 ff ff ff       	call   801607 <vcprintf>
	va_end(ap);

	return cnt;
}
  801680:	c9                   	leave  
  801681:	c3                   	ret    
	...

00801684 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	57                   	push   %edi
  801688:	56                   	push   %esi
  801689:	53                   	push   %ebx
  80168a:	83 ec 3c             	sub    $0x3c,%esp
  80168d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801690:	89 d7                	mov    %edx,%edi
  801692:	8b 45 08             	mov    0x8(%ebp),%eax
  801695:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801698:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80169e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8016a1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	75 08                	jne    8016b0 <printnum+0x2c>
  8016a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8016ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016ae:	77 57                	ja     801707 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016b0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8016b4:	4b                   	dec    %ebx
  8016b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8016b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8016bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016c0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8016c4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8016c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8016cf:	00 
  8016d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8016d3:	89 04 24             	mov    %eax,(%esp)
  8016d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016dd:	e8 7a 06 00 00       	call   801d5c <__udivdi3>
  8016e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016e6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016ea:	89 04 24             	mov    %eax,(%esp)
  8016ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8016f1:	89 fa                	mov    %edi,%edx
  8016f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016f6:	e8 89 ff ff ff       	call   801684 <printnum>
  8016fb:	eb 0f                	jmp    80170c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8016fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801701:	89 34 24             	mov    %esi,(%esp)
  801704:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801707:	4b                   	dec    %ebx
  801708:	85 db                	test   %ebx,%ebx
  80170a:	7f f1                	jg     8016fd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80170c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801710:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801714:	8b 45 10             	mov    0x10(%ebp),%eax
  801717:	89 44 24 08          	mov    %eax,0x8(%esp)
  80171b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801722:	00 
  801723:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801726:	89 04 24             	mov    %eax,(%esp)
  801729:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80172c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801730:	e8 47 07 00 00       	call   801e7c <__umoddi3>
  801735:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801739:	0f be 80 27 21 80 00 	movsbl 0x802127(%eax),%eax
  801740:	89 04 24             	mov    %eax,(%esp)
  801743:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801746:	83 c4 3c             	add    $0x3c,%esp
  801749:	5b                   	pop    %ebx
  80174a:	5e                   	pop    %esi
  80174b:	5f                   	pop    %edi
  80174c:	5d                   	pop    %ebp
  80174d:	c3                   	ret    

0080174e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801751:	83 fa 01             	cmp    $0x1,%edx
  801754:	7e 0e                	jle    801764 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801756:	8b 10                	mov    (%eax),%edx
  801758:	8d 4a 08             	lea    0x8(%edx),%ecx
  80175b:	89 08                	mov    %ecx,(%eax)
  80175d:	8b 02                	mov    (%edx),%eax
  80175f:	8b 52 04             	mov    0x4(%edx),%edx
  801762:	eb 22                	jmp    801786 <getuint+0x38>
	else if (lflag)
  801764:	85 d2                	test   %edx,%edx
  801766:	74 10                	je     801778 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801768:	8b 10                	mov    (%eax),%edx
  80176a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80176d:	89 08                	mov    %ecx,(%eax)
  80176f:	8b 02                	mov    (%edx),%eax
  801771:	ba 00 00 00 00       	mov    $0x0,%edx
  801776:	eb 0e                	jmp    801786 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801778:	8b 10                	mov    (%eax),%edx
  80177a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80177d:	89 08                	mov    %ecx,(%eax)
  80177f:	8b 02                	mov    (%edx),%eax
  801781:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801786:	5d                   	pop    %ebp
  801787:	c3                   	ret    

00801788 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80178e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801791:	8b 10                	mov    (%eax),%edx
  801793:	3b 50 04             	cmp    0x4(%eax),%edx
  801796:	73 08                	jae    8017a0 <sprintputch+0x18>
		*b->buf++ = ch;
  801798:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179b:	88 0a                	mov    %cl,(%edx)
  80179d:	42                   	inc    %edx
  80179e:	89 10                	mov    %edx,(%eax)
}
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    

008017a2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8017a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017af:	8b 45 10             	mov    0x10(%ebp),%eax
  8017b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c0:	89 04 24             	mov    %eax,(%esp)
  8017c3:	e8 02 00 00 00       	call   8017ca <vprintfmt>
	va_end(ap);
}
  8017c8:	c9                   	leave  
  8017c9:	c3                   	ret    

008017ca <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	57                   	push   %edi
  8017ce:	56                   	push   %esi
  8017cf:	53                   	push   %ebx
  8017d0:	83 ec 4c             	sub    $0x4c,%esp
  8017d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017d6:	8b 75 10             	mov    0x10(%ebp),%esi
  8017d9:	eb 12                	jmp    8017ed <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	0f 84 8b 03 00 00    	je     801b6e <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8017e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017e7:	89 04 24             	mov    %eax,(%esp)
  8017ea:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017ed:	0f b6 06             	movzbl (%esi),%eax
  8017f0:	46                   	inc    %esi
  8017f1:	83 f8 25             	cmp    $0x25,%eax
  8017f4:	75 e5                	jne    8017db <vprintfmt+0x11>
  8017f6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8017fa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801801:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801806:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80180d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801812:	eb 26                	jmp    80183a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801814:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801817:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80181b:	eb 1d                	jmp    80183a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80181d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801820:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801824:	eb 14                	jmp    80183a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801826:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801829:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801830:	eb 08                	jmp    80183a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801832:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801835:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183a:	0f b6 06             	movzbl (%esi),%eax
  80183d:	8d 56 01             	lea    0x1(%esi),%edx
  801840:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801843:	8a 16                	mov    (%esi),%dl
  801845:	83 ea 23             	sub    $0x23,%edx
  801848:	80 fa 55             	cmp    $0x55,%dl
  80184b:	0f 87 01 03 00 00    	ja     801b52 <vprintfmt+0x388>
  801851:	0f b6 d2             	movzbl %dl,%edx
  801854:	ff 24 95 60 22 80 00 	jmp    *0x802260(,%edx,4)
  80185b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80185e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801863:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801866:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80186a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80186d:	8d 50 d0             	lea    -0x30(%eax),%edx
  801870:	83 fa 09             	cmp    $0x9,%edx
  801873:	77 2a                	ja     80189f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801875:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801876:	eb eb                	jmp    801863 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801878:	8b 45 14             	mov    0x14(%ebp),%eax
  80187b:	8d 50 04             	lea    0x4(%eax),%edx
  80187e:	89 55 14             	mov    %edx,0x14(%ebp)
  801881:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801883:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801886:	eb 17                	jmp    80189f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801888:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80188c:	78 98                	js     801826 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80188e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801891:	eb a7                	jmp    80183a <vprintfmt+0x70>
  801893:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801896:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80189d:	eb 9b                	jmp    80183a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80189f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8018a3:	79 95                	jns    80183a <vprintfmt+0x70>
  8018a5:	eb 8b                	jmp    801832 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018a7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018ab:	eb 8d                	jmp    80183a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b0:	8d 50 04             	lea    0x4(%eax),%edx
  8018b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8018b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018ba:	8b 00                	mov    (%eax),%eax
  8018bc:	89 04 24             	mov    %eax,(%esp)
  8018bf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018c5:	e9 23 ff ff ff       	jmp    8017ed <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8018cd:	8d 50 04             	lea    0x4(%eax),%edx
  8018d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8018d3:	8b 00                	mov    (%eax),%eax
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	79 02                	jns    8018db <vprintfmt+0x111>
  8018d9:	f7 d8                	neg    %eax
  8018db:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8018dd:	83 f8 0f             	cmp    $0xf,%eax
  8018e0:	7f 0b                	jg     8018ed <vprintfmt+0x123>
  8018e2:	8b 04 85 c0 23 80 00 	mov    0x8023c0(,%eax,4),%eax
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	75 23                	jne    801910 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8018ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8018f1:	c7 44 24 08 3f 21 80 	movl   $0x80213f,0x8(%esp)
  8018f8:	00 
  8018f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801900:	89 04 24             	mov    %eax,(%esp)
  801903:	e8 9a fe ff ff       	call   8017a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801908:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80190b:	e9 dd fe ff ff       	jmp    8017ed <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801910:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801914:	c7 44 24 08 ca 20 80 	movl   $0x8020ca,0x8(%esp)
  80191b:	00 
  80191c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801920:	8b 55 08             	mov    0x8(%ebp),%edx
  801923:	89 14 24             	mov    %edx,(%esp)
  801926:	e8 77 fe ff ff       	call   8017a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80192b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80192e:	e9 ba fe ff ff       	jmp    8017ed <vprintfmt+0x23>
  801933:	89 f9                	mov    %edi,%ecx
  801935:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801938:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80193b:	8b 45 14             	mov    0x14(%ebp),%eax
  80193e:	8d 50 04             	lea    0x4(%eax),%edx
  801941:	89 55 14             	mov    %edx,0x14(%ebp)
  801944:	8b 30                	mov    (%eax),%esi
  801946:	85 f6                	test   %esi,%esi
  801948:	75 05                	jne    80194f <vprintfmt+0x185>
				p = "(null)";
  80194a:	be 38 21 80 00       	mov    $0x802138,%esi
			if (width > 0 && padc != '-')
  80194f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801953:	0f 8e 84 00 00 00    	jle    8019dd <vprintfmt+0x213>
  801959:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80195d:	74 7e                	je     8019dd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80195f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801963:	89 34 24             	mov    %esi,(%esp)
  801966:	e8 13 e8 ff ff       	call   80017e <strnlen>
  80196b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80196e:	29 c2                	sub    %eax,%edx
  801970:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801973:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801977:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80197a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80197d:	89 de                	mov    %ebx,%esi
  80197f:	89 d3                	mov    %edx,%ebx
  801981:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801983:	eb 0b                	jmp    801990 <vprintfmt+0x1c6>
					putch(padc, putdat);
  801985:	89 74 24 04          	mov    %esi,0x4(%esp)
  801989:	89 3c 24             	mov    %edi,(%esp)
  80198c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80198f:	4b                   	dec    %ebx
  801990:	85 db                	test   %ebx,%ebx
  801992:	7f f1                	jg     801985 <vprintfmt+0x1bb>
  801994:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801997:	89 f3                	mov    %esi,%ebx
  801999:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80199c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	79 05                	jns    8019a8 <vprintfmt+0x1de>
  8019a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8019ab:	29 c2                	sub    %eax,%edx
  8019ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8019b0:	eb 2b                	jmp    8019dd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019b2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019b6:	74 18                	je     8019d0 <vprintfmt+0x206>
  8019b8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8019bb:	83 fa 5e             	cmp    $0x5e,%edx
  8019be:	76 10                	jbe    8019d0 <vprintfmt+0x206>
					putch('?', putdat);
  8019c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019c4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8019cb:	ff 55 08             	call   *0x8(%ebp)
  8019ce:	eb 0a                	jmp    8019da <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8019d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019d4:	89 04 24             	mov    %eax,(%esp)
  8019d7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019da:	ff 4d e4             	decl   -0x1c(%ebp)
  8019dd:	0f be 06             	movsbl (%esi),%eax
  8019e0:	46                   	inc    %esi
  8019e1:	85 c0                	test   %eax,%eax
  8019e3:	74 21                	je     801a06 <vprintfmt+0x23c>
  8019e5:	85 ff                	test   %edi,%edi
  8019e7:	78 c9                	js     8019b2 <vprintfmt+0x1e8>
  8019e9:	4f                   	dec    %edi
  8019ea:	79 c6                	jns    8019b2 <vprintfmt+0x1e8>
  8019ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019ef:	89 de                	mov    %ebx,%esi
  8019f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8019f4:	eb 18                	jmp    801a0e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8019f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019fa:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801a01:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a03:	4b                   	dec    %ebx
  801a04:	eb 08                	jmp    801a0e <vprintfmt+0x244>
  801a06:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a09:	89 de                	mov    %ebx,%esi
  801a0b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801a0e:	85 db                	test   %ebx,%ebx
  801a10:	7f e4                	jg     8019f6 <vprintfmt+0x22c>
  801a12:	89 7d 08             	mov    %edi,0x8(%ebp)
  801a15:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a17:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801a1a:	e9 ce fd ff ff       	jmp    8017ed <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a1f:	83 f9 01             	cmp    $0x1,%ecx
  801a22:	7e 10                	jle    801a34 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801a24:	8b 45 14             	mov    0x14(%ebp),%eax
  801a27:	8d 50 08             	lea    0x8(%eax),%edx
  801a2a:	89 55 14             	mov    %edx,0x14(%ebp)
  801a2d:	8b 30                	mov    (%eax),%esi
  801a2f:	8b 78 04             	mov    0x4(%eax),%edi
  801a32:	eb 26                	jmp    801a5a <vprintfmt+0x290>
	else if (lflag)
  801a34:	85 c9                	test   %ecx,%ecx
  801a36:	74 12                	je     801a4a <vprintfmt+0x280>
		return va_arg(*ap, long);
  801a38:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3b:	8d 50 04             	lea    0x4(%eax),%edx
  801a3e:	89 55 14             	mov    %edx,0x14(%ebp)
  801a41:	8b 30                	mov    (%eax),%esi
  801a43:	89 f7                	mov    %esi,%edi
  801a45:	c1 ff 1f             	sar    $0x1f,%edi
  801a48:	eb 10                	jmp    801a5a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801a4a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a4d:	8d 50 04             	lea    0x4(%eax),%edx
  801a50:	89 55 14             	mov    %edx,0x14(%ebp)
  801a53:	8b 30                	mov    (%eax),%esi
  801a55:	89 f7                	mov    %esi,%edi
  801a57:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a5a:	85 ff                	test   %edi,%edi
  801a5c:	78 0a                	js     801a68 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a5e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a63:	e9 ac 00 00 00       	jmp    801b14 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801a68:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a6c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801a73:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801a76:	f7 de                	neg    %esi
  801a78:	83 d7 00             	adc    $0x0,%edi
  801a7b:	f7 df                	neg    %edi
			}
			base = 10;
  801a7d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a82:	e9 8d 00 00 00       	jmp    801b14 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a87:	89 ca                	mov    %ecx,%edx
  801a89:	8d 45 14             	lea    0x14(%ebp),%eax
  801a8c:	e8 bd fc ff ff       	call   80174e <getuint>
  801a91:	89 c6                	mov    %eax,%esi
  801a93:	89 d7                	mov    %edx,%edi
			base = 10;
  801a95:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801a9a:	eb 78                	jmp    801b14 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801a9c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aa0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  801aa7:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  801aaa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aae:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  801ab5:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  801ab8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801abc:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  801ac3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ac6:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  801ac9:	e9 1f fd ff ff       	jmp    8017ed <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  801ace:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ad2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801ad9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801adc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ae0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801ae7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801aea:	8b 45 14             	mov    0x14(%ebp),%eax
  801aed:	8d 50 04             	lea    0x4(%eax),%edx
  801af0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801af3:	8b 30                	mov    (%eax),%esi
  801af5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801afa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801aff:	eb 13                	jmp    801b14 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b01:	89 ca                	mov    %ecx,%edx
  801b03:	8d 45 14             	lea    0x14(%ebp),%eax
  801b06:	e8 43 fc ff ff       	call   80174e <getuint>
  801b0b:	89 c6                	mov    %eax,%esi
  801b0d:	89 d7                	mov    %edx,%edi
			base = 16;
  801b0f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b14:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801b18:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b1c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b1f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b23:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b27:	89 34 24             	mov    %esi,(%esp)
  801b2a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b2e:	89 da                	mov    %ebx,%edx
  801b30:	8b 45 08             	mov    0x8(%ebp),%eax
  801b33:	e8 4c fb ff ff       	call   801684 <printnum>
			break;
  801b38:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801b3b:	e9 ad fc ff ff       	jmp    8017ed <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b40:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b44:	89 04 24             	mov    %eax,(%esp)
  801b47:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b4a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b4d:	e9 9b fc ff ff       	jmp    8017ed <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b56:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801b5d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b60:	eb 01                	jmp    801b63 <vprintfmt+0x399>
  801b62:	4e                   	dec    %esi
  801b63:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801b67:	75 f9                	jne    801b62 <vprintfmt+0x398>
  801b69:	e9 7f fc ff ff       	jmp    8017ed <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801b6e:	83 c4 4c             	add    $0x4c,%esp
  801b71:	5b                   	pop    %ebx
  801b72:	5e                   	pop    %esi
  801b73:	5f                   	pop    %edi
  801b74:	5d                   	pop    %ebp
  801b75:	c3                   	ret    

00801b76 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	83 ec 28             	sub    $0x28,%esp
  801b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b82:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b85:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b89:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b93:	85 c0                	test   %eax,%eax
  801b95:	74 30                	je     801bc7 <vsnprintf+0x51>
  801b97:	85 d2                	test   %edx,%edx
  801b99:	7e 33                	jle    801bce <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b9b:	8b 45 14             	mov    0x14(%ebp),%eax
  801b9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ba2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ba9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb0:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  801bb7:	e8 0e fc ff ff       	call   8017ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bbf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc5:	eb 0c                	jmp    801bd3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bc7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bcc:	eb 05                	jmp    801bd3 <vsnprintf+0x5d>
  801bce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bd3:	c9                   	leave  
  801bd4:	c3                   	ret    

00801bd5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801bdb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801bde:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801be2:	8b 45 10             	mov    0x10(%ebp),%eax
  801be5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801be9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bec:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf3:	89 04 24             	mov    %eax,(%esp)
  801bf6:	e8 7b ff ff ff       	call   801b76 <vsnprintf>
	va_end(ap);

	return rc;
}
  801bfb:	c9                   	leave  
  801bfc:	c3                   	ret    
  801bfd:	00 00                	add    %al,(%eax)
	...

00801c00 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	56                   	push   %esi
  801c04:	53                   	push   %ebx
  801c05:	83 ec 10             	sub    $0x10,%esp
  801c08:	8b 75 08             	mov    0x8(%ebp),%esi
  801c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801c11:	85 c0                	test   %eax,%eax
  801c13:	75 05                	jne    801c1a <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801c15:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801c1a:	89 04 24             	mov    %eax,(%esp)
  801c1d:	e8 81 eb ff ff       	call   8007a3 <sys_ipc_recv>
	if (!err) {
  801c22:	85 c0                	test   %eax,%eax
  801c24:	75 26                	jne    801c4c <ipc_recv+0x4c>
		if (from_env_store) {
  801c26:	85 f6                	test   %esi,%esi
  801c28:	74 0a                	je     801c34 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801c2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801c2f:	8b 40 74             	mov    0x74(%eax),%eax
  801c32:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801c34:	85 db                	test   %ebx,%ebx
  801c36:	74 0a                	je     801c42 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801c38:	a1 04 40 80 00       	mov    0x804004,%eax
  801c3d:	8b 40 78             	mov    0x78(%eax),%eax
  801c40:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801c42:	a1 04 40 80 00       	mov    0x804004,%eax
  801c47:	8b 40 70             	mov    0x70(%eax),%eax
  801c4a:	eb 14                	jmp    801c60 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801c4c:	85 f6                	test   %esi,%esi
  801c4e:	74 06                	je     801c56 <ipc_recv+0x56>
		*from_env_store = 0;
  801c50:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801c56:	85 db                	test   %ebx,%ebx
  801c58:	74 06                	je     801c60 <ipc_recv+0x60>
		*perm_store = 0;
  801c5a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5d                   	pop    %ebp
  801c66:	c3                   	ret    

00801c67 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	57                   	push   %edi
  801c6b:	56                   	push   %esi
  801c6c:	53                   	push   %ebx
  801c6d:	83 ec 1c             	sub    $0x1c,%esp
  801c70:	8b 75 10             	mov    0x10(%ebp),%esi
  801c73:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801c76:	85 f6                	test   %esi,%esi
  801c78:	75 05                	jne    801c7f <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801c7a:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801c7f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c83:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c91:	89 04 24             	mov    %eax,(%esp)
  801c94:	e8 e7 ea ff ff       	call   800780 <sys_ipc_try_send>
  801c99:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801c9b:	e8 ce e8 ff ff       	call   80056e <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801ca0:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801ca3:	74 da                	je     801c7f <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801ca5:	85 db                	test   %ebx,%ebx
  801ca7:	74 20                	je     801cc9 <ipc_send+0x62>
		panic("send fail: %e", err);
  801ca9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801cad:	c7 44 24 08 20 24 80 	movl   $0x802420,0x8(%esp)
  801cb4:	00 
  801cb5:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801cbc:	00 
  801cbd:	c7 04 24 2e 24 80 00 	movl   $0x80242e,(%esp)
  801cc4:	e8 a7 f8 ff ff       	call   801570 <_panic>
	}
	return;
}
  801cc9:	83 c4 1c             	add    $0x1c,%esp
  801ccc:	5b                   	pop    %ebx
  801ccd:	5e                   	pop    %esi
  801cce:	5f                   	pop    %edi
  801ccf:	5d                   	pop    %ebp
  801cd0:	c3                   	ret    

00801cd1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	53                   	push   %ebx
  801cd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801cd8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cdd:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ce4:	89 c2                	mov    %eax,%edx
  801ce6:	c1 e2 07             	shl    $0x7,%edx
  801ce9:	29 ca                	sub    %ecx,%edx
  801ceb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cf1:	8b 52 50             	mov    0x50(%edx),%edx
  801cf4:	39 da                	cmp    %ebx,%edx
  801cf6:	75 0f                	jne    801d07 <ipc_find_env+0x36>
			return envs[i].env_id;
  801cf8:	c1 e0 07             	shl    $0x7,%eax
  801cfb:	29 c8                	sub    %ecx,%eax
  801cfd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d02:	8b 40 40             	mov    0x40(%eax),%eax
  801d05:	eb 0c                	jmp    801d13 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d07:	40                   	inc    %eax
  801d08:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d0d:	75 ce                	jne    801cdd <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d0f:	66 b8 00 00          	mov    $0x0,%ax
}
  801d13:	5b                   	pop    %ebx
  801d14:	5d                   	pop    %ebp
  801d15:	c3                   	ret    
	...

00801d18 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d1e:	89 c2                	mov    %eax,%edx
  801d20:	c1 ea 16             	shr    $0x16,%edx
  801d23:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d2a:	f6 c2 01             	test   $0x1,%dl
  801d2d:	74 1e                	je     801d4d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d2f:	c1 e8 0c             	shr    $0xc,%eax
  801d32:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d39:	a8 01                	test   $0x1,%al
  801d3b:	74 17                	je     801d54 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d3d:	c1 e8 0c             	shr    $0xc,%eax
  801d40:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d47:	ef 
  801d48:	0f b7 c0             	movzwl %ax,%eax
  801d4b:	eb 0c                	jmp    801d59 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d52:	eb 05                	jmp    801d59 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d54:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d59:	5d                   	pop    %ebp
  801d5a:	c3                   	ret    
	...

00801d5c <__udivdi3>:
  801d5c:	55                   	push   %ebp
  801d5d:	57                   	push   %edi
  801d5e:	56                   	push   %esi
  801d5f:	83 ec 10             	sub    $0x10,%esp
  801d62:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d66:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801d6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d6e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d72:	89 cd                	mov    %ecx,%ebp
  801d74:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801d78:	85 c0                	test   %eax,%eax
  801d7a:	75 2c                	jne    801da8 <__udivdi3+0x4c>
  801d7c:	39 f9                	cmp    %edi,%ecx
  801d7e:	77 68                	ja     801de8 <__udivdi3+0x8c>
  801d80:	85 c9                	test   %ecx,%ecx
  801d82:	75 0b                	jne    801d8f <__udivdi3+0x33>
  801d84:	b8 01 00 00 00       	mov    $0x1,%eax
  801d89:	31 d2                	xor    %edx,%edx
  801d8b:	f7 f1                	div    %ecx
  801d8d:	89 c1                	mov    %eax,%ecx
  801d8f:	31 d2                	xor    %edx,%edx
  801d91:	89 f8                	mov    %edi,%eax
  801d93:	f7 f1                	div    %ecx
  801d95:	89 c7                	mov    %eax,%edi
  801d97:	89 f0                	mov    %esi,%eax
  801d99:	f7 f1                	div    %ecx
  801d9b:	89 c6                	mov    %eax,%esi
  801d9d:	89 f0                	mov    %esi,%eax
  801d9f:	89 fa                	mov    %edi,%edx
  801da1:	83 c4 10             	add    $0x10,%esp
  801da4:	5e                   	pop    %esi
  801da5:	5f                   	pop    %edi
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    
  801da8:	39 f8                	cmp    %edi,%eax
  801daa:	77 2c                	ja     801dd8 <__udivdi3+0x7c>
  801dac:	0f bd f0             	bsr    %eax,%esi
  801daf:	83 f6 1f             	xor    $0x1f,%esi
  801db2:	75 4c                	jne    801e00 <__udivdi3+0xa4>
  801db4:	39 f8                	cmp    %edi,%eax
  801db6:	bf 00 00 00 00       	mov    $0x0,%edi
  801dbb:	72 0a                	jb     801dc7 <__udivdi3+0x6b>
  801dbd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801dc1:	0f 87 ad 00 00 00    	ja     801e74 <__udivdi3+0x118>
  801dc7:	be 01 00 00 00       	mov    $0x1,%esi
  801dcc:	89 f0                	mov    %esi,%eax
  801dce:	89 fa                	mov    %edi,%edx
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	5e                   	pop    %esi
  801dd4:	5f                   	pop    %edi
  801dd5:	5d                   	pop    %ebp
  801dd6:	c3                   	ret    
  801dd7:	90                   	nop
  801dd8:	31 ff                	xor    %edi,%edi
  801dda:	31 f6                	xor    %esi,%esi
  801ddc:	89 f0                	mov    %esi,%eax
  801dde:	89 fa                	mov    %edi,%edx
  801de0:	83 c4 10             	add    $0x10,%esp
  801de3:	5e                   	pop    %esi
  801de4:	5f                   	pop    %edi
  801de5:	5d                   	pop    %ebp
  801de6:	c3                   	ret    
  801de7:	90                   	nop
  801de8:	89 fa                	mov    %edi,%edx
  801dea:	89 f0                	mov    %esi,%eax
  801dec:	f7 f1                	div    %ecx
  801dee:	89 c6                	mov    %eax,%esi
  801df0:	31 ff                	xor    %edi,%edi
  801df2:	89 f0                	mov    %esi,%eax
  801df4:	89 fa                	mov    %edi,%edx
  801df6:	83 c4 10             	add    $0x10,%esp
  801df9:	5e                   	pop    %esi
  801dfa:	5f                   	pop    %edi
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    
  801dfd:	8d 76 00             	lea    0x0(%esi),%esi
  801e00:	89 f1                	mov    %esi,%ecx
  801e02:	d3 e0                	shl    %cl,%eax
  801e04:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e08:	b8 20 00 00 00       	mov    $0x20,%eax
  801e0d:	29 f0                	sub    %esi,%eax
  801e0f:	89 ea                	mov    %ebp,%edx
  801e11:	88 c1                	mov    %al,%cl
  801e13:	d3 ea                	shr    %cl,%edx
  801e15:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801e19:	09 ca                	or     %ecx,%edx
  801e1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e1f:	89 f1                	mov    %esi,%ecx
  801e21:	d3 e5                	shl    %cl,%ebp
  801e23:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801e27:	89 fd                	mov    %edi,%ebp
  801e29:	88 c1                	mov    %al,%cl
  801e2b:	d3 ed                	shr    %cl,%ebp
  801e2d:	89 fa                	mov    %edi,%edx
  801e2f:	89 f1                	mov    %esi,%ecx
  801e31:	d3 e2                	shl    %cl,%edx
  801e33:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e37:	88 c1                	mov    %al,%cl
  801e39:	d3 ef                	shr    %cl,%edi
  801e3b:	09 d7                	or     %edx,%edi
  801e3d:	89 f8                	mov    %edi,%eax
  801e3f:	89 ea                	mov    %ebp,%edx
  801e41:	f7 74 24 08          	divl   0x8(%esp)
  801e45:	89 d1                	mov    %edx,%ecx
  801e47:	89 c7                	mov    %eax,%edi
  801e49:	f7 64 24 0c          	mull   0xc(%esp)
  801e4d:	39 d1                	cmp    %edx,%ecx
  801e4f:	72 17                	jb     801e68 <__udivdi3+0x10c>
  801e51:	74 09                	je     801e5c <__udivdi3+0x100>
  801e53:	89 fe                	mov    %edi,%esi
  801e55:	31 ff                	xor    %edi,%edi
  801e57:	e9 41 ff ff ff       	jmp    801d9d <__udivdi3+0x41>
  801e5c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e60:	89 f1                	mov    %esi,%ecx
  801e62:	d3 e2                	shl    %cl,%edx
  801e64:	39 c2                	cmp    %eax,%edx
  801e66:	73 eb                	jae    801e53 <__udivdi3+0xf7>
  801e68:	8d 77 ff             	lea    -0x1(%edi),%esi
  801e6b:	31 ff                	xor    %edi,%edi
  801e6d:	e9 2b ff ff ff       	jmp    801d9d <__udivdi3+0x41>
  801e72:	66 90                	xchg   %ax,%ax
  801e74:	31 f6                	xor    %esi,%esi
  801e76:	e9 22 ff ff ff       	jmp    801d9d <__udivdi3+0x41>
	...

00801e7c <__umoddi3>:
  801e7c:	55                   	push   %ebp
  801e7d:	57                   	push   %edi
  801e7e:	56                   	push   %esi
  801e7f:	83 ec 20             	sub    $0x20,%esp
  801e82:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e86:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801e8a:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e8e:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e92:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e96:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801e9a:	89 c7                	mov    %eax,%edi
  801e9c:	89 f2                	mov    %esi,%edx
  801e9e:	85 ed                	test   %ebp,%ebp
  801ea0:	75 16                	jne    801eb8 <__umoddi3+0x3c>
  801ea2:	39 f1                	cmp    %esi,%ecx
  801ea4:	0f 86 a6 00 00 00    	jbe    801f50 <__umoddi3+0xd4>
  801eaa:	f7 f1                	div    %ecx
  801eac:	89 d0                	mov    %edx,%eax
  801eae:	31 d2                	xor    %edx,%edx
  801eb0:	83 c4 20             	add    $0x20,%esp
  801eb3:	5e                   	pop    %esi
  801eb4:	5f                   	pop    %edi
  801eb5:	5d                   	pop    %ebp
  801eb6:	c3                   	ret    
  801eb7:	90                   	nop
  801eb8:	39 f5                	cmp    %esi,%ebp
  801eba:	0f 87 ac 00 00 00    	ja     801f6c <__umoddi3+0xf0>
  801ec0:	0f bd c5             	bsr    %ebp,%eax
  801ec3:	83 f0 1f             	xor    $0x1f,%eax
  801ec6:	89 44 24 10          	mov    %eax,0x10(%esp)
  801eca:	0f 84 a8 00 00 00    	je     801f78 <__umoddi3+0xfc>
  801ed0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ed4:	d3 e5                	shl    %cl,%ebp
  801ed6:	bf 20 00 00 00       	mov    $0x20,%edi
  801edb:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801edf:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ee3:	89 f9                	mov    %edi,%ecx
  801ee5:	d3 e8                	shr    %cl,%eax
  801ee7:	09 e8                	or     %ebp,%eax
  801ee9:	89 44 24 18          	mov    %eax,0x18(%esp)
  801eed:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ef1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ef5:	d3 e0                	shl    %cl,%eax
  801ef7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801efb:	89 f2                	mov    %esi,%edx
  801efd:	d3 e2                	shl    %cl,%edx
  801eff:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f03:	d3 e0                	shl    %cl,%eax
  801f05:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801f09:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f0d:	89 f9                	mov    %edi,%ecx
  801f0f:	d3 e8                	shr    %cl,%eax
  801f11:	09 d0                	or     %edx,%eax
  801f13:	d3 ee                	shr    %cl,%esi
  801f15:	89 f2                	mov    %esi,%edx
  801f17:	f7 74 24 18          	divl   0x18(%esp)
  801f1b:	89 d6                	mov    %edx,%esi
  801f1d:	f7 64 24 0c          	mull   0xc(%esp)
  801f21:	89 c5                	mov    %eax,%ebp
  801f23:	89 d1                	mov    %edx,%ecx
  801f25:	39 d6                	cmp    %edx,%esi
  801f27:	72 67                	jb     801f90 <__umoddi3+0x114>
  801f29:	74 75                	je     801fa0 <__umoddi3+0x124>
  801f2b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f2f:	29 e8                	sub    %ebp,%eax
  801f31:	19 ce                	sbb    %ecx,%esi
  801f33:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f37:	d3 e8                	shr    %cl,%eax
  801f39:	89 f2                	mov    %esi,%edx
  801f3b:	89 f9                	mov    %edi,%ecx
  801f3d:	d3 e2                	shl    %cl,%edx
  801f3f:	09 d0                	or     %edx,%eax
  801f41:	89 f2                	mov    %esi,%edx
  801f43:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f47:	d3 ea                	shr    %cl,%edx
  801f49:	83 c4 20             	add    $0x20,%esp
  801f4c:	5e                   	pop    %esi
  801f4d:	5f                   	pop    %edi
  801f4e:	5d                   	pop    %ebp
  801f4f:	c3                   	ret    
  801f50:	85 c9                	test   %ecx,%ecx
  801f52:	75 0b                	jne    801f5f <__umoddi3+0xe3>
  801f54:	b8 01 00 00 00       	mov    $0x1,%eax
  801f59:	31 d2                	xor    %edx,%edx
  801f5b:	f7 f1                	div    %ecx
  801f5d:	89 c1                	mov    %eax,%ecx
  801f5f:	89 f0                	mov    %esi,%eax
  801f61:	31 d2                	xor    %edx,%edx
  801f63:	f7 f1                	div    %ecx
  801f65:	89 f8                	mov    %edi,%eax
  801f67:	e9 3e ff ff ff       	jmp    801eaa <__umoddi3+0x2e>
  801f6c:	89 f2                	mov    %esi,%edx
  801f6e:	83 c4 20             	add    $0x20,%esp
  801f71:	5e                   	pop    %esi
  801f72:	5f                   	pop    %edi
  801f73:	5d                   	pop    %ebp
  801f74:	c3                   	ret    
  801f75:	8d 76 00             	lea    0x0(%esi),%esi
  801f78:	39 f5                	cmp    %esi,%ebp
  801f7a:	72 04                	jb     801f80 <__umoddi3+0x104>
  801f7c:	39 f9                	cmp    %edi,%ecx
  801f7e:	77 06                	ja     801f86 <__umoddi3+0x10a>
  801f80:	89 f2                	mov    %esi,%edx
  801f82:	29 cf                	sub    %ecx,%edi
  801f84:	19 ea                	sbb    %ebp,%edx
  801f86:	89 f8                	mov    %edi,%eax
  801f88:	83 c4 20             	add    $0x20,%esp
  801f8b:	5e                   	pop    %esi
  801f8c:	5f                   	pop    %edi
  801f8d:	5d                   	pop    %ebp
  801f8e:	c3                   	ret    
  801f8f:	90                   	nop
  801f90:	89 d1                	mov    %edx,%ecx
  801f92:	89 c5                	mov    %eax,%ebp
  801f94:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f98:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f9c:	eb 8d                	jmp    801f2b <__umoddi3+0xaf>
  801f9e:	66 90                	xchg   %ax,%ax
  801fa0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801fa4:	72 ea                	jb     801f90 <__umoddi3+0x114>
  801fa6:	89 f1                	mov    %esi,%ecx
  801fa8:	eb 81                	jmp    801f2b <__umoddi3+0xaf>

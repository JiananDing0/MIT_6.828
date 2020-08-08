
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 63 09 00 00       	call   800994 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int t;

	if (s == 0) {
  800043:	85 db                	test   %ebx,%ebx
  800045:	75 1e                	jne    800065 <_gettoken+0x31>
		if (debug > 1)
  800047:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80004e:	0f 8e 19 01 00 00    	jle    80016d <_gettoken+0x139>
			cprintf("GETTOKEN NULL\n");
  800054:	c7 04 24 20 35 80 00 	movl   $0x803520,(%esp)
  80005b:	e8 9c 0a 00 00       	call   800afc <cprintf>
  800060:	e9 1b 01 00 00       	jmp    800180 <_gettoken+0x14c>
		return 0;
	}

	if (debug > 1)
  800065:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80006c:	7e 10                	jle    80007e <_gettoken+0x4a>
		cprintf("GETTOKEN: %s\n", s);
  80006e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800072:	c7 04 24 2f 35 80 00 	movl   $0x80352f,(%esp)
  800079:	e8 7e 0a 00 00       	call   800afc <cprintf>

	*p1 = 0;
  80007e:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	*p2 = 0;
  800084:	8b 45 10             	mov    0x10(%ebp),%eax
  800087:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80008d:	eb 04                	jmp    800093 <_gettoken+0x5f>
		*s++ = 0;
  80008f:	c6 03 00             	movb   $0x0,(%ebx)
  800092:	43                   	inc    %ebx
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  800093:	0f be 03             	movsbl (%ebx),%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 3d 35 80 00 	movl   $0x80353d,(%esp)
  8000a1:	e8 fb 11 00 00       	call   8012a1 <strchr>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 e5                	jne    80008f <_gettoken+0x5b>
  8000aa:	89 de                	mov    %ebx,%esi
		*s++ = 0;
	if (*s == 0) {
  8000ac:	8a 03                	mov    (%ebx),%al
  8000ae:	84 c0                	test   %al,%al
  8000b0:	75 23                	jne    8000d5 <_gettoken+0xa1>
		if (debug > 1)
  8000b2:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000b9:	0f 8e b5 00 00 00    	jle    800174 <_gettoken+0x140>
			cprintf("EOL\n");
  8000bf:	c7 04 24 42 35 80 00 	movl   $0x803542,(%esp)
  8000c6:	e8 31 0a 00 00       	call   800afc <cprintf>
		return 0;
  8000cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000d0:	e9 ab 00 00 00       	jmp    800180 <_gettoken+0x14c>
	}
	if (strchr(SYMBOLS, *s)) {
  8000d5:	0f be c0             	movsbl %al,%eax
  8000d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000dc:	c7 04 24 53 35 80 00 	movl   $0x803553,(%esp)
  8000e3:	e8 b9 11 00 00       	call   8012a1 <strchr>
  8000e8:	85 c0                	test   %eax,%eax
  8000ea:	74 29                	je     800115 <_gettoken+0xe1>
		t = *s;
  8000ec:	0f be 1b             	movsbl (%ebx),%ebx
		*p1 = s;
  8000ef:	89 37                	mov    %esi,(%edi)
		*s++ = 0;
  8000f1:	c6 06 00             	movb   $0x0,(%esi)
  8000f4:	46                   	inc    %esi
  8000f5:	8b 55 10             	mov    0x10(%ebp),%edx
  8000f8:	89 32                	mov    %esi,(%edx)
		*p2 = s;
		if (debug > 1)
  8000fa:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800101:	7e 7d                	jle    800180 <_gettoken+0x14c>
			cprintf("TOK %c\n", t);
  800103:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800107:	c7 04 24 47 35 80 00 	movl   $0x803547,(%esp)
  80010e:	e8 e9 09 00 00       	call   800afc <cprintf>
  800113:	eb 6b                	jmp    800180 <_gettoken+0x14c>
		return t;
	}
	*p1 = s;
  800115:	89 1f                	mov    %ebx,(%edi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800117:	eb 01                	jmp    80011a <_gettoken+0xe6>
		s++;
  800119:	43                   	inc    %ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80011a:	8a 03                	mov    (%ebx),%al
  80011c:	84 c0                	test   %al,%al
  80011e:	74 17                	je     800137 <_gettoken+0x103>
  800120:	0f be c0             	movsbl %al,%eax
  800123:	89 44 24 04          	mov    %eax,0x4(%esp)
  800127:	c7 04 24 4f 35 80 00 	movl   $0x80354f,(%esp)
  80012e:	e8 6e 11 00 00       	call   8012a1 <strchr>
  800133:	85 c0                	test   %eax,%eax
  800135:	74 e2                	je     800119 <_gettoken+0xe5>
		s++;
	*p2 = s;
  800137:	8b 45 10             	mov    0x10(%ebp),%eax
  80013a:	89 18                	mov    %ebx,(%eax)
	if (debug > 1) {
  80013c:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800143:	7e 36                	jle    80017b <_gettoken+0x147>
		t = **p2;
  800145:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  800148:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  80014b:	8b 07                	mov    (%edi),%eax
  80014d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800151:	c7 04 24 5b 35 80 00 	movl   $0x80355b,(%esp)
  800158:	e8 9f 09 00 00       	call   800afc <cprintf>
		**p2 = t;
  80015d:	8b 55 10             	mov    0x10(%ebp),%edx
  800160:	8b 02                	mov    (%edx),%eax
  800162:	89 f2                	mov    %esi,%edx
  800164:	88 10                	mov    %dl,(%eax)
	}
	return 'w';
  800166:	bb 77 00 00 00       	mov    $0x77,%ebx
  80016b:	eb 13                	jmp    800180 <_gettoken+0x14c>
	int t;

	if (s == 0) {
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  80016d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800172:	eb 0c                	jmp    800180 <_gettoken+0x14c>
	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  800174:	bb 00 00 00 00       	mov    $0x0,%ebx
  800179:	eb 05                	jmp    800180 <_gettoken+0x14c>
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  80017b:	bb 77 00 00 00       	mov    $0x77,%ebx
}
  800180:	89 d8                	mov    %ebx,%eax
  800182:	83 c4 1c             	add    $0x1c,%esp
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    

0080018a <gettoken>:

int
gettoken(char *s, char **p1)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	83 ec 18             	sub    $0x18,%esp
  800190:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  800193:	85 c0                	test   %eax,%eax
  800195:	74 24                	je     8001bb <gettoken+0x31>
		nc = _gettoken(s, &np1, &np2);
  800197:	c7 44 24 08 08 50 80 	movl   $0x805008,0x8(%esp)
  80019e:	00 
  80019f:	c7 44 24 04 04 50 80 	movl   $0x805004,0x4(%esp)
  8001a6:	00 
  8001a7:	89 04 24             	mov    %eax,(%esp)
  8001aa:	e8 85 fe ff ff       	call   800034 <_gettoken>
  8001af:	a3 0c 50 80 00       	mov    %eax,0x80500c
		return 0;
  8001b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b9:	eb 3c                	jmp    8001f7 <gettoken+0x6d>
	}
	c = nc;
  8001bb:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8001c0:	a3 10 50 80 00       	mov    %eax,0x805010
	*p1 = np1;
  8001c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c8:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8001ce:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001d0:	c7 44 24 08 08 50 80 	movl   $0x805008,0x8(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 04 04 50 80 	movl   $0x805004,0x4(%esp)
  8001df:	00 
  8001e0:	a1 08 50 80 00       	mov    0x805008,%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	e8 47 fe ff ff       	call   800034 <_gettoken>
  8001ed:	a3 0c 50 80 00       	mov    %eax,0x80500c
	return c;
  8001f2:	a1 10 50 80 00       	mov    0x805010,%eax
}
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	57                   	push   %edi
  8001fd:	56                   	push   %esi
  8001fe:	53                   	push   %ebx
  8001ff:	81 ec 6c 04 00 00    	sub    $0x46c,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800205:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80020c:	00 
  80020d:	8b 45 08             	mov    0x8(%ebp),%eax
  800210:	89 04 24             	mov    %eax,(%esp)
  800213:	e8 72 ff ff ff       	call   80018a <gettoken>

again:
	argc = 0;
  800218:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80021d:	8d 5d a4             	lea    -0x5c(%ebp),%ebx
  800220:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800224:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80022b:	e8 5a ff ff ff       	call   80018a <gettoken>
  800230:	83 f8 77             	cmp    $0x77,%eax
  800233:	74 2e                	je     800263 <runcmd+0x6a>
  800235:	83 f8 77             	cmp    $0x77,%eax
  800238:	7f 1b                	jg     800255 <runcmd+0x5c>
  80023a:	83 f8 3c             	cmp    $0x3c,%eax
  80023d:	74 44                	je     800283 <runcmd+0x8a>
  80023f:	83 f8 3e             	cmp    $0x3e,%eax
  800242:	0f 84 80 00 00 00    	je     8002c8 <runcmd+0xcf>
  800248:	85 c0                	test   %eax,%eax
  80024a:	0f 84 06 02 00 00    	je     800456 <runcmd+0x25d>
  800250:	e9 e1 01 00 00       	jmp    800436 <runcmd+0x23d>
  800255:	83 f8 7c             	cmp    $0x7c,%eax
  800258:	0f 85 d8 01 00 00    	jne    800436 <runcmd+0x23d>
  80025e:	e9 e6 00 00 00       	jmp    800349 <runcmd+0x150>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  800263:	83 fe 10             	cmp    $0x10,%esi
  800266:	75 11                	jne    800279 <runcmd+0x80>
				cprintf("too many arguments\n");
  800268:	c7 04 24 65 35 80 00 	movl   $0x803565,(%esp)
  80026f:	e8 88 08 00 00       	call   800afc <cprintf>
				exit();
  800274:	e8 6f 07 00 00       	call   8009e8 <exit>
			}
			argv[argc++] = t;
  800279:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80027c:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  800280:	46                   	inc    %esi
			break;
  800281:	eb 9d                	jmp    800220 <runcmd+0x27>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800283:	8d 45 a4             	lea    -0x5c(%ebp),%eax
  800286:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800291:	e8 f4 fe ff ff       	call   80018a <gettoken>
  800296:	83 f8 77             	cmp    $0x77,%eax
  800299:	74 11                	je     8002ac <runcmd+0xb3>
				cprintf("syntax error: < not followed by word\n");
  80029b:	c7 04 24 b8 36 80 00 	movl   $0x8036b8,(%esp)
  8002a2:	e8 55 08 00 00       	call   800afc <cprintf>
				exit();
  8002a7:	e8 3c 07 00 00       	call   8009e8 <exit>
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			panic("< redirection not implemented");
  8002ac:	c7 44 24 08 79 35 80 	movl   $0x803579,0x8(%esp)
  8002b3:	00 
  8002b4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8002bb:	00 
  8002bc:	c7 04 24 97 35 80 00 	movl   $0x803597,(%esp)
  8002c3:	e8 3c 07 00 00       	call   800a04 <_panic>
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  8002c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002d3:	e8 b2 fe ff ff       	call   80018a <gettoken>
  8002d8:	83 f8 77             	cmp    $0x77,%eax
  8002db:	74 11                	je     8002ee <runcmd+0xf5>
				cprintf("syntax error: > not followed by word\n");
  8002dd:	c7 04 24 e0 36 80 00 	movl   $0x8036e0,(%esp)
  8002e4:	e8 13 08 00 00       	call   800afc <cprintf>
				exit();
  8002e9:	e8 fa 06 00 00       	call   8009e8 <exit>
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  8002ee:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
  8002f5:	00 
  8002f6:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  8002f9:	89 04 24             	mov    %eax,(%esp)
  8002fc:	e8 24 22 00 00       	call   802525 <open>
  800301:	89 c7                	mov    %eax,%edi
  800303:	85 c0                	test   %eax,%eax
  800305:	79 1c                	jns    800323 <runcmd+0x12a>
				cprintf("open %s for write: %e", t, fd);
  800307:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80030e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800312:	c7 04 24 a1 35 80 00 	movl   $0x8035a1,(%esp)
  800319:	e8 de 07 00 00       	call   800afc <cprintf>
				exit();
  80031e:	e8 c5 06 00 00       	call   8009e8 <exit>
			}
			if (fd != 1) {
  800323:	83 ff 01             	cmp    $0x1,%edi
  800326:	0f 84 f4 fe ff ff    	je     800220 <runcmd+0x27>
				dup(fd, 1);
  80032c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800333:	00 
  800334:	89 3c 24             	mov    %edi,(%esp)
  800337:	e8 2f 1c 00 00       	call   801f6b <dup>
				close(fd);
  80033c:	89 3c 24             	mov    %edi,(%esp)
  80033f:	e8 d6 1b 00 00       	call   801f1a <close>
  800344:	e9 d7 fe ff ff       	jmp    800220 <runcmd+0x27>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  800349:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  80034f:	89 04 24             	mov    %eax,(%esp)
  800352:	e8 46 2b 00 00       	call   802e9d <pipe>
  800357:	85 c0                	test   %eax,%eax
  800359:	79 15                	jns    800370 <runcmd+0x177>
				cprintf("pipe: %e", r);
  80035b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035f:	c7 04 24 b7 35 80 00 	movl   $0x8035b7,(%esp)
  800366:	e8 91 07 00 00       	call   800afc <cprintf>
				exit();
  80036b:	e8 78 06 00 00       	call   8009e8 <exit>
			}
			if (debug)
  800370:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800377:	74 20                	je     800399 <runcmd+0x1a0>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  800379:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80037f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800383:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800389:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038d:	c7 04 24 c0 35 80 00 	movl   $0x8035c0,(%esp)
  800394:	e8 63 07 00 00       	call   800afc <cprintf>
			if ((r = fork()) < 0) {
  800399:	e8 75 15 00 00       	call   801913 <fork>
  80039e:	89 c7                	mov    %eax,%edi
  8003a0:	85 c0                	test   %eax,%eax
  8003a2:	79 15                	jns    8003b9 <runcmd+0x1c0>
				cprintf("fork: %e", r);
  8003a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a8:	c7 04 24 51 3b 80 00 	movl   $0x803b51,(%esp)
  8003af:	e8 48 07 00 00       	call   800afc <cprintf>
				exit();
  8003b4:	e8 2f 06 00 00       	call   8009e8 <exit>
			}
			if (r == 0) {
  8003b9:	85 ff                	test   %edi,%edi
  8003bb:	75 40                	jne    8003fd <runcmd+0x204>
				if (p[0] != 0) {
  8003bd:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003c3:	85 c0                	test   %eax,%eax
  8003c5:	74 1e                	je     8003e5 <runcmd+0x1ec>
					dup(p[0], 0);
  8003c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003ce:	00 
  8003cf:	89 04 24             	mov    %eax,(%esp)
  8003d2:	e8 94 1b 00 00       	call   801f6b <dup>
					close(p[0]);
  8003d7:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003dd:	89 04 24             	mov    %eax,(%esp)
  8003e0:	e8 35 1b 00 00       	call   801f1a <close>
				}
				close(p[1]);
  8003e5:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  8003eb:	89 04 24             	mov    %eax,(%esp)
  8003ee:	e8 27 1b 00 00       	call   801f1a <close>

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  8003f3:	be 00 00 00 00       	mov    $0x0,%esi
				if (p[0] != 0) {
					dup(p[0], 0);
					close(p[0]);
				}
				close(p[1]);
				goto again;
  8003f8:	e9 23 fe ff ff       	jmp    800220 <runcmd+0x27>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  8003fd:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800403:	83 f8 01             	cmp    $0x1,%eax
  800406:	74 1e                	je     800426 <runcmd+0x22d>
					dup(p[1], 1);
  800408:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80040f:	00 
  800410:	89 04 24             	mov    %eax,(%esp)
  800413:	e8 53 1b 00 00       	call   801f6b <dup>
					close(p[1]);
  800418:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80041e:	89 04 24             	mov    %eax,(%esp)
  800421:	e8 f4 1a 00 00       	call   801f1a <close>
				}
				close(p[0]);
  800426:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  80042c:	89 04 24             	mov    %eax,(%esp)
  80042f:	e8 e6 1a 00 00       	call   801f1a <close>
				goto runit;
  800434:	eb 25                	jmp    80045b <runcmd+0x262>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800436:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043a:	c7 44 24 08 cd 35 80 	movl   $0x8035cd,0x8(%esp)
  800441:	00 
  800442:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  800449:	00 
  80044a:	c7 04 24 97 35 80 00 	movl   $0x803597,(%esp)
  800451:	e8 ae 05 00 00       	call   800a04 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800456:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  80045b:	85 f6                	test   %esi,%esi
  80045d:	75 1e                	jne    80047d <runcmd+0x284>
		if (debug)
  80045f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800466:	0f 84 76 01 00 00    	je     8005e2 <runcmd+0x3e9>
			cprintf("EMPTY COMMAND\n");
  80046c:	c7 04 24 e9 35 80 00 	movl   $0x8035e9,(%esp)
  800473:	e8 84 06 00 00       	call   800afc <cprintf>
  800478:	e9 65 01 00 00       	jmp    8005e2 <runcmd+0x3e9>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  80047d:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800480:	80 38 2f             	cmpb   $0x2f,(%eax)
  800483:	74 22                	je     8004a7 <runcmd+0x2ae>
		argv0buf[0] = '/';
  800485:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  80048c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800490:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  800496:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	e8 03 0d 00 00       	call   8011a7 <strcpy>
		argv[0] = argv0buf;
  8004a4:	89 5d a8             	mov    %ebx,-0x58(%ebp)
	}
	argv[argc] = 0;
  8004a7:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004ae:	00 

	// Print the command.
	if (debug) {
  8004af:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004b6:	74 43                	je     8004fb <runcmd+0x302>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004b8:	a1 24 54 80 00       	mov    0x805424,%eax
  8004bd:	8b 40 48             	mov    0x48(%eax),%eax
  8004c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c4:	c7 04 24 f8 35 80 00 	movl   $0x8035f8,(%esp)
  8004cb:	e8 2c 06 00 00       	call   800afc <cprintf>
  8004d0:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  8004d3:	eb 10                	jmp    8004e5 <runcmd+0x2ec>
			cprintf(" %s", argv[i]);
  8004d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d9:	c7 04 24 83 36 80 00 	movl   $0x803683,(%esp)
  8004e0:	e8 17 06 00 00       	call   800afc <cprintf>
  8004e5:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  8004e8:	8b 43 fc             	mov    -0x4(%ebx),%eax
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	75 e6                	jne    8004d5 <runcmd+0x2dc>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  8004ef:	c7 04 24 40 35 80 00 	movl   $0x803540,(%esp)
  8004f6:	e8 01 06 00 00       	call   800afc <cprintf>
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  8004fb:	8d 45 a8             	lea    -0x58(%ebp),%eax
  8004fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800502:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800505:	89 04 24             	mov    %eax,(%esp)
  800508:	e8 ef 21 00 00       	call   8026fc <spawn>
  80050d:	89 c3                	mov    %eax,%ebx
  80050f:	85 c0                	test   %eax,%eax
  800511:	79 1e                	jns    800531 <runcmd+0x338>
		cprintf("spawn %s: %e\n", argv[0], r);
  800513:	89 44 24 08          	mov    %eax,0x8(%esp)
  800517:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80051a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051e:	c7 04 24 06 36 80 00 	movl   $0x803606,(%esp)
  800525:	e8 d2 05 00 00       	call   800afc <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  80052a:	e8 1c 1a 00 00       	call   801f4b <close_all>
  80052f:	eb 5a                	jmp    80058b <runcmd+0x392>
  800531:	e8 15 1a 00 00       	call   801f4b <close_all>
	if (r >= 0) {
		if (debug)
  800536:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80053d:	74 23                	je     800562 <runcmd+0x369>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  80053f:	a1 24 54 80 00       	mov    0x805424,%eax
  800544:	8b 40 48             	mov    0x48(%eax),%eax
  800547:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80054b:	8b 55 a8             	mov    -0x58(%ebp),%edx
  80054e:	89 54 24 08          	mov    %edx,0x8(%esp)
  800552:	89 44 24 04          	mov    %eax,0x4(%esp)
  800556:	c7 04 24 14 36 80 00 	movl   $0x803614,(%esp)
  80055d:	e8 9a 05 00 00       	call   800afc <cprintf>
		wait(r);
  800562:	89 1c 24             	mov    %ebx,(%esp)
  800565:	e8 d6 2a 00 00       	call   803040 <wait>
		if (debug)
  80056a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800571:	74 18                	je     80058b <runcmd+0x392>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800573:	a1 24 54 80 00       	mov    0x805424,%eax
  800578:	8b 40 48             	mov    0x48(%eax),%eax
  80057b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057f:	c7 04 24 29 36 80 00 	movl   $0x803629,(%esp)
  800586:	e8 71 05 00 00       	call   800afc <cprintf>
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80058b:	85 ff                	test   %edi,%edi
  80058d:	74 4e                	je     8005dd <runcmd+0x3e4>
		if (debug)
  80058f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800596:	74 1c                	je     8005b4 <runcmd+0x3bb>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  800598:	a1 24 54 80 00       	mov    0x805424,%eax
  80059d:	8b 40 48             	mov    0x48(%eax),%eax
  8005a0:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a8:	c7 04 24 3f 36 80 00 	movl   $0x80363f,(%esp)
  8005af:	e8 48 05 00 00       	call   800afc <cprintf>
		wait(pipe_child);
  8005b4:	89 3c 24             	mov    %edi,(%esp)
  8005b7:	e8 84 2a 00 00       	call   803040 <wait>
		if (debug)
  8005bc:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005c3:	74 18                	je     8005dd <runcmd+0x3e4>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005c5:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ca:	8b 40 48             	mov    0x48(%eax),%eax
  8005cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d1:	c7 04 24 29 36 80 00 	movl   $0x803629,(%esp)
  8005d8:	e8 1f 05 00 00       	call   800afc <cprintf>
	}

	// Done!
	exit();
  8005dd:	e8 06 04 00 00       	call   8009e8 <exit>
}
  8005e2:	81 c4 6c 04 00 00    	add    $0x46c,%esp
  8005e8:	5b                   	pop    %ebx
  8005e9:	5e                   	pop    %esi
  8005ea:	5f                   	pop    %edi
  8005eb:	5d                   	pop    %ebp
  8005ec:	c3                   	ret    

008005ed <usage>:
}


void
usage(void)
{
  8005ed:	55                   	push   %ebp
  8005ee:	89 e5                	mov    %esp,%ebp
  8005f0:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  8005f3:	c7 04 24 08 37 80 00 	movl   $0x803708,(%esp)
  8005fa:	e8 fd 04 00 00       	call   800afc <cprintf>
	exit();
  8005ff:	e8 e4 03 00 00       	call   8009e8 <exit>
}
  800604:	c9                   	leave  
  800605:	c3                   	ret    

00800606 <umain>:

void
umain(int argc, char **argv)
{
  800606:	55                   	push   %ebp
  800607:	89 e5                	mov    %esp,%ebp
  800609:	57                   	push   %edi
  80060a:	56                   	push   %esi
  80060b:	53                   	push   %ebx
  80060c:	83 ec 4c             	sub    $0x4c,%esp
  80060f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800612:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800615:	89 44 24 08          	mov    %eax,0x8(%esp)
  800619:	89 74 24 04          	mov    %esi,0x4(%esp)
  80061d:	8d 45 08             	lea    0x8(%ebp),%eax
  800620:	89 04 24             	mov    %eax,(%esp)
  800623:	e8 e4 15 00 00       	call   801c0c <argstart>
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800628:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80062f:	bf 3f 00 00 00       	mov    $0x3f,%edi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800634:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800637:	eb 2e                	jmp    800667 <umain+0x61>
		switch (r) {
  800639:	83 f8 69             	cmp    $0x69,%eax
  80063c:	74 0c                	je     80064a <umain+0x44>
  80063e:	83 f8 78             	cmp    $0x78,%eax
  800641:	74 1d                	je     800660 <umain+0x5a>
  800643:	83 f8 64             	cmp    $0x64,%eax
  800646:	75 11                	jne    800659 <umain+0x53>
  800648:	eb 07                	jmp    800651 <umain+0x4b>
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  80064a:	bf 01 00 00 00       	mov    $0x1,%edi
  80064f:	eb 16                	jmp    800667 <umain+0x61>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  800651:	ff 05 00 50 80 00    	incl   0x805000
			break;
  800657:	eb 0e                	jmp    800667 <umain+0x61>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  800659:	e8 8f ff ff ff       	call   8005ed <usage>
  80065e:	eb 07                	jmp    800667 <umain+0x61>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800660:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800667:	89 1c 24             	mov    %ebx,(%esp)
  80066a:	e8 d6 15 00 00       	call   801c45 <argnext>
  80066f:	85 c0                	test   %eax,%eax
  800671:	79 c6                	jns    800639 <umain+0x33>
  800673:	89 fb                	mov    %edi,%ebx
			break;
		default:
			usage();
		}

	if (argc > 2)
  800675:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  800679:	7e 05                	jle    800680 <umain+0x7a>
		usage();
  80067b:	e8 6d ff ff ff       	call   8005ed <usage>
	if (argc == 2) {
  800680:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  800684:	75 72                	jne    8006f8 <umain+0xf2>
		close(0);
  800686:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80068d:	e8 88 18 00 00       	call   801f1a <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  800692:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800699:	00 
  80069a:	8b 46 04             	mov    0x4(%esi),%eax
  80069d:	89 04 24             	mov    %eax,(%esp)
  8006a0:	e8 80 1e 00 00       	call   802525 <open>
  8006a5:	85 c0                	test   %eax,%eax
  8006a7:	79 27                	jns    8006d0 <umain+0xca>
			panic("open %s: %e", argv[1], r);
  8006a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ad:	8b 46 04             	mov    0x4(%esi),%eax
  8006b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b4:	c7 44 24 08 5f 36 80 	movl   $0x80365f,0x8(%esp)
  8006bb:	00 
  8006bc:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  8006c3:	00 
  8006c4:	c7 04 24 97 35 80 00 	movl   $0x803597,(%esp)
  8006cb:	e8 34 03 00 00       	call   800a04 <_panic>
		assert(r == 0);
  8006d0:	85 c0                	test   %eax,%eax
  8006d2:	74 24                	je     8006f8 <umain+0xf2>
  8006d4:	c7 44 24 0c 6b 36 80 	movl   $0x80366b,0xc(%esp)
  8006db:	00 
  8006dc:	c7 44 24 08 72 36 80 	movl   $0x803672,0x8(%esp)
  8006e3:	00 
  8006e4:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
  8006eb:	00 
  8006ec:	c7 04 24 97 35 80 00 	movl   $0x803597,(%esp)
  8006f3:	e8 0c 03 00 00       	call   800a04 <_panic>
	}
	if (interactive == '?')
  8006f8:	83 fb 3f             	cmp    $0x3f,%ebx
  8006fb:	75 0e                	jne    80070b <umain+0x105>
		interactive = iscons(0);
  8006fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800704:	e8 08 02 00 00       	call   800911 <iscons>
  800709:	89 c7                	mov    %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80070b:	85 ff                	test   %edi,%edi
  80070d:	74 07                	je     800716 <umain+0x110>
  80070f:	b8 5c 36 80 00       	mov    $0x80365c,%eax
  800714:	eb 05                	jmp    80071b <umain+0x115>
  800716:	b8 00 00 00 00       	mov    $0x0,%eax
  80071b:	89 04 24             	mov    %eax,(%esp)
  80071e:	e8 71 09 00 00       	call   801094 <readline>
  800723:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800725:	85 c0                	test   %eax,%eax
  800727:	75 1a                	jne    800743 <umain+0x13d>
			if (debug)
  800729:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800730:	74 0c                	je     80073e <umain+0x138>
				cprintf("EXITING\n");
  800732:	c7 04 24 87 36 80 00 	movl   $0x803687,(%esp)
  800739:	e8 be 03 00 00       	call   800afc <cprintf>
			exit();	// end of file
  80073e:	e8 a5 02 00 00       	call   8009e8 <exit>
		}
		if (debug)
  800743:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80074a:	74 10                	je     80075c <umain+0x156>
			cprintf("LINE: %s\n", buf);
  80074c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800750:	c7 04 24 90 36 80 00 	movl   $0x803690,(%esp)
  800757:	e8 a0 03 00 00       	call   800afc <cprintf>
		if (buf[0] == '#')
  80075c:	80 3b 23             	cmpb   $0x23,(%ebx)
  80075f:	74 aa                	je     80070b <umain+0x105>
			continue;
		if (echocmds)
  800761:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800765:	74 10                	je     800777 <umain+0x171>
			printf("# %s\n", buf);
  800767:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076b:	c7 04 24 9a 36 80 00 	movl   $0x80369a,(%esp)
  800772:	e8 62 1f 00 00       	call   8026d9 <printf>
		if (debug)
  800777:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80077e:	74 0c                	je     80078c <umain+0x186>
			cprintf("BEFORE FORK\n");
  800780:	c7 04 24 a0 36 80 00 	movl   $0x8036a0,(%esp)
  800787:	e8 70 03 00 00       	call   800afc <cprintf>
		if ((r = fork()) < 0)
  80078c:	e8 82 11 00 00       	call   801913 <fork>
  800791:	89 c6                	mov    %eax,%esi
  800793:	85 c0                	test   %eax,%eax
  800795:	79 20                	jns    8007b7 <umain+0x1b1>
			panic("fork: %e", r);
  800797:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079b:	c7 44 24 08 51 3b 80 	movl   $0x803b51,0x8(%esp)
  8007a2:	00 
  8007a3:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  8007aa:	00 
  8007ab:	c7 04 24 97 35 80 00 	movl   $0x803597,(%esp)
  8007b2:	e8 4d 02 00 00       	call   800a04 <_panic>
		if (debug)
  8007b7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007be:	74 10                	je     8007d0 <umain+0x1ca>
			cprintf("FORK: %d\n", r);
  8007c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c4:	c7 04 24 ad 36 80 00 	movl   $0x8036ad,(%esp)
  8007cb:	e8 2c 03 00 00       	call   800afc <cprintf>
		if (r == 0) {
  8007d0:	85 f6                	test   %esi,%esi
  8007d2:	75 12                	jne    8007e6 <umain+0x1e0>
			runcmd(buf);
  8007d4:	89 1c 24             	mov    %ebx,(%esp)
  8007d7:	e8 1d fa ff ff       	call   8001f9 <runcmd>
			exit();
  8007dc:	e8 07 02 00 00       	call   8009e8 <exit>
  8007e1:	e9 25 ff ff ff       	jmp    80070b <umain+0x105>
		} else
			wait(r);
  8007e6:	89 34 24             	mov    %esi,(%esp)
  8007e9:	e8 52 28 00 00       	call   803040 <wait>
  8007ee:	e9 18 ff ff ff       	jmp    80070b <umain+0x105>
	...

008007f4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800804:	c7 44 24 04 29 37 80 	movl   $0x803729,0x4(%esp)
  80080b:	00 
  80080c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080f:	89 04 24             	mov    %eax,(%esp)
  800812:	e8 90 09 00 00       	call   8011a7 <strcpy>
	return 0;
}
  800817:	b8 00 00 00 00       	mov    $0x0,%eax
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	57                   	push   %edi
  800822:	56                   	push   %esi
  800823:	53                   	push   %ebx
  800824:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80082a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80082f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800835:	eb 30                	jmp    800867 <devcons_write+0x49>
		m = n - tot;
  800837:	8b 75 10             	mov    0x10(%ebp),%esi
  80083a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80083c:	83 fe 7f             	cmp    $0x7f,%esi
  80083f:	76 05                	jbe    800846 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  800841:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800846:	89 74 24 08          	mov    %esi,0x8(%esp)
  80084a:	03 45 0c             	add    0xc(%ebp),%eax
  80084d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800851:	89 3c 24             	mov    %edi,(%esp)
  800854:	e8 c7 0a 00 00       	call   801320 <memmove>
		sys_cputs(buf, m);
  800859:	89 74 24 04          	mov    %esi,0x4(%esp)
  80085d:	89 3c 24             	mov    %edi,(%esp)
  800860:	e8 67 0c 00 00       	call   8014cc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800865:	01 f3                	add    %esi,%ebx
  800867:	89 d8                	mov    %ebx,%eax
  800869:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80086c:	72 c9                	jb     800837 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80086e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  800874:	5b                   	pop    %ebx
  800875:	5e                   	pop    %esi
  800876:	5f                   	pop    %edi
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80087f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800883:	75 07                	jne    80088c <devcons_read+0x13>
  800885:	eb 25                	jmp    8008ac <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800887:	e8 ee 0c 00 00       	call   80157a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80088c:	e8 59 0c 00 00       	call   8014ea <sys_cgetc>
  800891:	85 c0                	test   %eax,%eax
  800893:	74 f2                	je     800887 <devcons_read+0xe>
  800895:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800897:	85 c0                	test   %eax,%eax
  800899:	78 1d                	js     8008b8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80089b:	83 f8 04             	cmp    $0x4,%eax
  80089e:	74 13                	je     8008b3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8008a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a3:	88 10                	mov    %dl,(%eax)
	return 1;
  8008a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8008aa:	eb 0c                	jmp    8008b8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b1:	eb 05                	jmp    8008b8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    

008008ba <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8008cd:	00 
  8008ce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008d1:	89 04 24             	mov    %eax,(%esp)
  8008d4:	e8 f3 0b 00 00       	call   8014cc <sys_cputs>
}
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <getchar>:

int
getchar(void)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8008e1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8008e8:	00 
  8008e9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8008f7:	e8 82 17 00 00       	call   80207e <read>
	if (r < 0)
  8008fc:	85 c0                	test   %eax,%eax
  8008fe:	78 0f                	js     80090f <getchar+0x34>
		return r;
	if (r < 1)
  800900:	85 c0                	test   %eax,%eax
  800902:	7e 06                	jle    80090a <getchar+0x2f>
		return -E_EOF;
	return c;
  800904:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800908:	eb 05                	jmp    80090f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80090a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80090f:	c9                   	leave  
  800910:	c3                   	ret    

00800911 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800917:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80091a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	89 04 24             	mov    %eax,(%esp)
  800924:	e8 b9 14 00 00       	call   801de2 <fd_lookup>
  800929:	85 c0                	test   %eax,%eax
  80092b:	78 11                	js     80093e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80092d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800930:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800936:	39 10                	cmp    %edx,(%eax)
  800938:	0f 94 c0             	sete   %al
  80093b:	0f b6 c0             	movzbl %al,%eax
}
  80093e:	c9                   	leave  
  80093f:	c3                   	ret    

00800940 <opencons>:

int
opencons(void)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800946:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800949:	89 04 24             	mov    %eax,(%esp)
  80094c:	e8 3e 14 00 00       	call   801d8f <fd_alloc>
  800951:	85 c0                	test   %eax,%eax
  800953:	78 3c                	js     800991 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800955:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80095c:	00 
  80095d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800960:	89 44 24 04          	mov    %eax,0x4(%esp)
  800964:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80096b:	e8 29 0c 00 00       	call   801599 <sys_page_alloc>
  800970:	85 c0                	test   %eax,%eax
  800972:	78 1d                	js     800991 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800974:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80097a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80097d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80097f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800982:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800989:	89 04 24             	mov    %eax,(%esp)
  80098c:	e8 d3 13 00 00       	call   801d64 <fd2num>
}
  800991:	c9                   	leave  
  800992:	c3                   	ret    
	...

00800994 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	83 ec 10             	sub    $0x10,%esp
  80099c:	8b 75 08             	mov    0x8(%ebp),%esi
  80099f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8009a2:	e8 b4 0b 00 00       	call   80155b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8009a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009ac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8009b3:	c1 e0 07             	shl    $0x7,%eax
  8009b6:	29 d0                	sub    %edx,%eax
  8009b8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009bd:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009c2:	85 f6                	test   %esi,%esi
  8009c4:	7e 07                	jle    8009cd <libmain+0x39>
		binaryname = argv[0];
  8009c6:	8b 03                	mov    (%ebx),%eax
  8009c8:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009d1:	89 34 24             	mov    %esi,(%esp)
  8009d4:	e8 2d fc ff ff       	call   800606 <umain>

	// exit gracefully
	exit();
  8009d9:	e8 0a 00 00 00       	call   8009e8 <exit>
}
  8009de:	83 c4 10             	add    $0x10,%esp
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    
  8009e5:	00 00                	add    %al,(%eax)
	...

008009e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8009ee:	e8 58 15 00 00       	call   801f4b <close_all>
	sys_env_destroy(0);
  8009f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009fa:	e8 0a 0b 00 00       	call   801509 <sys_env_destroy>
}
  8009ff:	c9                   	leave  
  800a00:	c3                   	ret    
  800a01:	00 00                	add    %al,(%eax)
	...

00800a04 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800a0c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a0f:	8b 1d 1c 40 80 00    	mov    0x80401c,%ebx
  800a15:	e8 41 0b 00 00       	call   80155b <sys_getenvid>
  800a1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a21:	8b 55 08             	mov    0x8(%ebp),%edx
  800a24:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a28:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a30:	c7 04 24 40 37 80 00 	movl   $0x803740,(%esp)
  800a37:	e8 c0 00 00 00       	call   800afc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a3c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a40:	8b 45 10             	mov    0x10(%ebp),%eax
  800a43:	89 04 24             	mov    %eax,(%esp)
  800a46:	e8 50 00 00 00       	call   800a9b <vcprintf>
	cprintf("\n");
  800a4b:	c7 04 24 40 35 80 00 	movl   $0x803540,(%esp)
  800a52:	e8 a5 00 00 00       	call   800afc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a57:	cc                   	int3   
  800a58:	eb fd                	jmp    800a57 <_panic+0x53>
	...

00800a5c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	53                   	push   %ebx
  800a60:	83 ec 14             	sub    $0x14,%esp
  800a63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a66:	8b 03                	mov    (%ebx),%eax
  800a68:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800a6f:	40                   	inc    %eax
  800a70:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800a72:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a77:	75 19                	jne    800a92 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800a79:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800a80:	00 
  800a81:	8d 43 08             	lea    0x8(%ebx),%eax
  800a84:	89 04 24             	mov    %eax,(%esp)
  800a87:	e8 40 0a 00 00       	call   8014cc <sys_cputs>
		b->idx = 0;
  800a8c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800a92:	ff 43 04             	incl   0x4(%ebx)
}
  800a95:	83 c4 14             	add    $0x14,%esp
  800a98:	5b                   	pop    %ebx
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800aa4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800aab:	00 00 00 
	b.cnt = 0;
  800aae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ab5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad0:	c7 04 24 5c 0a 80 00 	movl   $0x800a5c,(%esp)
  800ad7:	e8 82 01 00 00       	call   800c5e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800adc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800aec:	89 04 24             	mov    %eax,(%esp)
  800aef:	e8 d8 09 00 00       	call   8014cc <sys_cputs>

	return b.cnt;
}
  800af4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800afa:	c9                   	leave  
  800afb:	c3                   	ret    

00800afc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b02:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	89 04 24             	mov    %eax,(%esp)
  800b0f:	e8 87 ff ff ff       	call   800a9b <vcprintf>
	va_end(ap);

	return cnt;
}
  800b14:	c9                   	leave  
  800b15:	c3                   	ret    
	...

00800b18 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 3c             	sub    $0x3c,%esp
  800b21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
  800b29:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b32:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800b35:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b38:	85 c0                	test   %eax,%eax
  800b3a:	75 08                	jne    800b44 <printnum+0x2c>
  800b3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b3f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b42:	77 57                	ja     800b9b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b44:	89 74 24 10          	mov    %esi,0x10(%esp)
  800b48:	4b                   	dec    %ebx
  800b49:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800b4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b50:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b54:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800b58:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800b5c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b63:	00 
  800b64:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b67:	89 04 24             	mov    %eax,(%esp)
  800b6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b71:	e8 56 27 00 00       	call   8032cc <__udivdi3>
  800b76:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b7a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b7e:	89 04 24             	mov    %eax,(%esp)
  800b81:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b85:	89 fa                	mov    %edi,%edx
  800b87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b8a:	e8 89 ff ff ff       	call   800b18 <printnum>
  800b8f:	eb 0f                	jmp    800ba0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b91:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b95:	89 34 24             	mov    %esi,(%esp)
  800b98:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b9b:	4b                   	dec    %ebx
  800b9c:	85 db                	test   %ebx,%ebx
  800b9e:	7f f1                	jg     800b91 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800ba0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ba4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ba8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bab:	89 44 24 08          	mov    %eax,0x8(%esp)
  800baf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800bb6:	00 
  800bb7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800bba:	89 04 24             	mov    %eax,(%esp)
  800bbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800bc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc4:	e8 23 28 00 00       	call   8033ec <__umoddi3>
  800bc9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bcd:	0f be 80 63 37 80 00 	movsbl 0x803763(%eax),%eax
  800bd4:	89 04 24             	mov    %eax,(%esp)
  800bd7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800bda:	83 c4 3c             	add    $0x3c,%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800be5:	83 fa 01             	cmp    $0x1,%edx
  800be8:	7e 0e                	jle    800bf8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bea:	8b 10                	mov    (%eax),%edx
  800bec:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bef:	89 08                	mov    %ecx,(%eax)
  800bf1:	8b 02                	mov    (%edx),%eax
  800bf3:	8b 52 04             	mov    0x4(%edx),%edx
  800bf6:	eb 22                	jmp    800c1a <getuint+0x38>
	else if (lflag)
  800bf8:	85 d2                	test   %edx,%edx
  800bfa:	74 10                	je     800c0c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bfc:	8b 10                	mov    (%eax),%edx
  800bfe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c01:	89 08                	mov    %ecx,(%eax)
  800c03:	8b 02                	mov    (%edx),%eax
  800c05:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0a:	eb 0e                	jmp    800c1a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800c0c:	8b 10                	mov    (%eax),%edx
  800c0e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c11:	89 08                	mov    %ecx,(%eax)
  800c13:	8b 02                	mov    (%edx),%eax
  800c15:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c22:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800c25:	8b 10                	mov    (%eax),%edx
  800c27:	3b 50 04             	cmp    0x4(%eax),%edx
  800c2a:	73 08                	jae    800c34 <sprintputch+0x18>
		*b->buf++ = ch;
  800c2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2f:	88 0a                	mov    %cl,(%edx)
  800c31:	42                   	inc    %edx
  800c32:	89 10                	mov    %edx,(%eax)
}
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c3c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c43:	8b 45 10             	mov    0x10(%ebp),%eax
  800c46:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c51:	8b 45 08             	mov    0x8(%ebp),%eax
  800c54:	89 04 24             	mov    %eax,(%esp)
  800c57:	e8 02 00 00 00       	call   800c5e <vprintfmt>
	va_end(ap);
}
  800c5c:	c9                   	leave  
  800c5d:	c3                   	ret    

00800c5e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	83 ec 4c             	sub    $0x4c,%esp
  800c67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c6a:	8b 75 10             	mov    0x10(%ebp),%esi
  800c6d:	eb 12                	jmp    800c81 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	0f 84 8b 03 00 00    	je     801002 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800c77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c7b:	89 04 24             	mov    %eax,(%esp)
  800c7e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c81:	0f b6 06             	movzbl (%esi),%eax
  800c84:	46                   	inc    %esi
  800c85:	83 f8 25             	cmp    $0x25,%eax
  800c88:	75 e5                	jne    800c6f <vprintfmt+0x11>
  800c8a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800c8e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800c95:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800c9a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800ca1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca6:	eb 26                	jmp    800cce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800cab:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800caf:	eb 1d                	jmp    800cce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cb1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800cb4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800cb8:	eb 14                	jmp    800cce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800cbd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800cc4:	eb 08                	jmp    800cce <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800cc6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800cc9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cce:	0f b6 06             	movzbl (%esi),%eax
  800cd1:	8d 56 01             	lea    0x1(%esi),%edx
  800cd4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800cd7:	8a 16                	mov    (%esi),%dl
  800cd9:	83 ea 23             	sub    $0x23,%edx
  800cdc:	80 fa 55             	cmp    $0x55,%dl
  800cdf:	0f 87 01 03 00 00    	ja     800fe6 <vprintfmt+0x388>
  800ce5:	0f b6 d2             	movzbl %dl,%edx
  800ce8:	ff 24 95 a0 38 80 00 	jmp    *0x8038a0(,%edx,4)
  800cef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800cf2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cf7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800cfa:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800cfe:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800d01:	8d 50 d0             	lea    -0x30(%eax),%edx
  800d04:	83 fa 09             	cmp    $0x9,%edx
  800d07:	77 2a                	ja     800d33 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800d09:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800d0a:	eb eb                	jmp    800cf7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800d0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d0f:	8d 50 04             	lea    0x4(%eax),%edx
  800d12:	89 55 14             	mov    %edx,0x14(%ebp)
  800d15:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d17:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800d1a:	eb 17                	jmp    800d33 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800d1c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d20:	78 98                	js     800cba <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d22:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d25:	eb a7                	jmp    800cce <vprintfmt+0x70>
  800d27:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d2a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800d31:	eb 9b                	jmp    800cce <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800d33:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d37:	79 95                	jns    800cce <vprintfmt+0x70>
  800d39:	eb 8b                	jmp    800cc6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d3b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d3f:	eb 8d                	jmp    800cce <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d41:	8b 45 14             	mov    0x14(%ebp),%eax
  800d44:	8d 50 04             	lea    0x4(%eax),%edx
  800d47:	89 55 14             	mov    %edx,0x14(%ebp)
  800d4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d4e:	8b 00                	mov    (%eax),%eax
  800d50:	89 04 24             	mov    %eax,(%esp)
  800d53:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d56:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d59:	e9 23 ff ff ff       	jmp    800c81 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d5e:	8b 45 14             	mov    0x14(%ebp),%eax
  800d61:	8d 50 04             	lea    0x4(%eax),%edx
  800d64:	89 55 14             	mov    %edx,0x14(%ebp)
  800d67:	8b 00                	mov    (%eax),%eax
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	79 02                	jns    800d6f <vprintfmt+0x111>
  800d6d:	f7 d8                	neg    %eax
  800d6f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d71:	83 f8 0f             	cmp    $0xf,%eax
  800d74:	7f 0b                	jg     800d81 <vprintfmt+0x123>
  800d76:	8b 04 85 00 3a 80 00 	mov    0x803a00(,%eax,4),%eax
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	75 23                	jne    800da4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800d81:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d85:	c7 44 24 08 7b 37 80 	movl   $0x80377b,0x8(%esp)
  800d8c:	00 
  800d8d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
  800d94:	89 04 24             	mov    %eax,(%esp)
  800d97:	e8 9a fe ff ff       	call   800c36 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d9c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d9f:	e9 dd fe ff ff       	jmp    800c81 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800da4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800da8:	c7 44 24 08 84 36 80 	movl   $0x803684,0x8(%esp)
  800daf:	00 
  800db0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	89 14 24             	mov    %edx,(%esp)
  800dba:	e8 77 fe ff ff       	call   800c36 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dbf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800dc2:	e9 ba fe ff ff       	jmp    800c81 <vprintfmt+0x23>
  800dc7:	89 f9                	mov    %edi,%ecx
  800dc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dcc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800dcf:	8b 45 14             	mov    0x14(%ebp),%eax
  800dd2:	8d 50 04             	lea    0x4(%eax),%edx
  800dd5:	89 55 14             	mov    %edx,0x14(%ebp)
  800dd8:	8b 30                	mov    (%eax),%esi
  800dda:	85 f6                	test   %esi,%esi
  800ddc:	75 05                	jne    800de3 <vprintfmt+0x185>
				p = "(null)";
  800dde:	be 74 37 80 00       	mov    $0x803774,%esi
			if (width > 0 && padc != '-')
  800de3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800de7:	0f 8e 84 00 00 00    	jle    800e71 <vprintfmt+0x213>
  800ded:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800df1:	74 7e                	je     800e71 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800df3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800df7:	89 34 24             	mov    %esi,(%esp)
  800dfa:	e8 8b 03 00 00       	call   80118a <strnlen>
  800dff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e02:	29 c2                	sub    %eax,%edx
  800e04:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800e07:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800e0b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800e0e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800e11:	89 de                	mov    %ebx,%esi
  800e13:	89 d3                	mov    %edx,%ebx
  800e15:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e17:	eb 0b                	jmp    800e24 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800e19:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e1d:	89 3c 24             	mov    %edi,(%esp)
  800e20:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e23:	4b                   	dec    %ebx
  800e24:	85 db                	test   %ebx,%ebx
  800e26:	7f f1                	jg     800e19 <vprintfmt+0x1bb>
  800e28:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800e2b:	89 f3                	mov    %esi,%ebx
  800e2d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800e30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e33:	85 c0                	test   %eax,%eax
  800e35:	79 05                	jns    800e3c <vprintfmt+0x1de>
  800e37:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e3f:	29 c2                	sub    %eax,%edx
  800e41:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e44:	eb 2b                	jmp    800e71 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e46:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e4a:	74 18                	je     800e64 <vprintfmt+0x206>
  800e4c:	8d 50 e0             	lea    -0x20(%eax),%edx
  800e4f:	83 fa 5e             	cmp    $0x5e,%edx
  800e52:	76 10                	jbe    800e64 <vprintfmt+0x206>
					putch('?', putdat);
  800e54:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e58:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800e5f:	ff 55 08             	call   *0x8(%ebp)
  800e62:	eb 0a                	jmp    800e6e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800e64:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e68:	89 04 24             	mov    %eax,(%esp)
  800e6b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e6e:	ff 4d e4             	decl   -0x1c(%ebp)
  800e71:	0f be 06             	movsbl (%esi),%eax
  800e74:	46                   	inc    %esi
  800e75:	85 c0                	test   %eax,%eax
  800e77:	74 21                	je     800e9a <vprintfmt+0x23c>
  800e79:	85 ff                	test   %edi,%edi
  800e7b:	78 c9                	js     800e46 <vprintfmt+0x1e8>
  800e7d:	4f                   	dec    %edi
  800e7e:	79 c6                	jns    800e46 <vprintfmt+0x1e8>
  800e80:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e83:	89 de                	mov    %ebx,%esi
  800e85:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800e88:	eb 18                	jmp    800ea2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e8a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e8e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800e95:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e97:	4b                   	dec    %ebx
  800e98:	eb 08                	jmp    800ea2 <vprintfmt+0x244>
  800e9a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e9d:	89 de                	mov    %ebx,%esi
  800e9f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ea2:	85 db                	test   %ebx,%ebx
  800ea4:	7f e4                	jg     800e8a <vprintfmt+0x22c>
  800ea6:	89 7d 08             	mov    %edi,0x8(%ebp)
  800ea9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800eab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800eae:	e9 ce fd ff ff       	jmp    800c81 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800eb3:	83 f9 01             	cmp    $0x1,%ecx
  800eb6:	7e 10                	jle    800ec8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800eb8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ebb:	8d 50 08             	lea    0x8(%eax),%edx
  800ebe:	89 55 14             	mov    %edx,0x14(%ebp)
  800ec1:	8b 30                	mov    (%eax),%esi
  800ec3:	8b 78 04             	mov    0x4(%eax),%edi
  800ec6:	eb 26                	jmp    800eee <vprintfmt+0x290>
	else if (lflag)
  800ec8:	85 c9                	test   %ecx,%ecx
  800eca:	74 12                	je     800ede <vprintfmt+0x280>
		return va_arg(*ap, long);
  800ecc:	8b 45 14             	mov    0x14(%ebp),%eax
  800ecf:	8d 50 04             	lea    0x4(%eax),%edx
  800ed2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ed5:	8b 30                	mov    (%eax),%esi
  800ed7:	89 f7                	mov    %esi,%edi
  800ed9:	c1 ff 1f             	sar    $0x1f,%edi
  800edc:	eb 10                	jmp    800eee <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800ede:	8b 45 14             	mov    0x14(%ebp),%eax
  800ee1:	8d 50 04             	lea    0x4(%eax),%edx
  800ee4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ee7:	8b 30                	mov    (%eax),%esi
  800ee9:	89 f7                	mov    %esi,%edi
  800eeb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800eee:	85 ff                	test   %edi,%edi
  800ef0:	78 0a                	js     800efc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ef2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef7:	e9 ac 00 00 00       	jmp    800fa8 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800efc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f00:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800f07:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800f0a:	f7 de                	neg    %esi
  800f0c:	83 d7 00             	adc    $0x0,%edi
  800f0f:	f7 df                	neg    %edi
			}
			base = 10;
  800f11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f16:	e9 8d 00 00 00       	jmp    800fa8 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f1b:	89 ca                	mov    %ecx,%edx
  800f1d:	8d 45 14             	lea    0x14(%ebp),%eax
  800f20:	e8 bd fc ff ff       	call   800be2 <getuint>
  800f25:	89 c6                	mov    %eax,%esi
  800f27:	89 d7                	mov    %edx,%edi
			base = 10;
  800f29:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800f2e:	eb 78                	jmp    800fa8 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800f30:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f34:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800f3b:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800f3e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f42:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800f49:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800f4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f50:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800f57:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f5a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800f5d:	e9 1f fd ff ff       	jmp    800c81 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800f62:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f66:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800f6d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800f70:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f74:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800f7b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f7e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f81:	8d 50 04             	lea    0x4(%eax),%edx
  800f84:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f87:	8b 30                	mov    (%eax),%esi
  800f89:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f8e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800f93:	eb 13                	jmp    800fa8 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f95:	89 ca                	mov    %ecx,%edx
  800f97:	8d 45 14             	lea    0x14(%ebp),%eax
  800f9a:	e8 43 fc ff ff       	call   800be2 <getuint>
  800f9f:	89 c6                	mov    %eax,%esi
  800fa1:	89 d7                	mov    %edx,%edi
			base = 16;
  800fa3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800fa8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800fac:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fb0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fb3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fb7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fbb:	89 34 24             	mov    %esi,(%esp)
  800fbe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fc2:	89 da                	mov    %ebx,%edx
  800fc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc7:	e8 4c fb ff ff       	call   800b18 <printnum>
			break;
  800fcc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800fcf:	e9 ad fc ff ff       	jmp    800c81 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fd4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fd8:	89 04 24             	mov    %eax,(%esp)
  800fdb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fde:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fe1:	e9 9b fc ff ff       	jmp    800c81 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fe6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ff1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ff4:	eb 01                	jmp    800ff7 <vprintfmt+0x399>
  800ff6:	4e                   	dec    %esi
  800ff7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800ffb:	75 f9                	jne    800ff6 <vprintfmt+0x398>
  800ffd:	e9 7f fc ff ff       	jmp    800c81 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801002:	83 c4 4c             	add    $0x4c,%esp
  801005:	5b                   	pop    %ebx
  801006:	5e                   	pop    %esi
  801007:	5f                   	pop    %edi
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    

0080100a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	83 ec 28             	sub    $0x28,%esp
  801010:	8b 45 08             	mov    0x8(%ebp),%eax
  801013:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801016:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801019:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80101d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801020:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801027:	85 c0                	test   %eax,%eax
  801029:	74 30                	je     80105b <vsnprintf+0x51>
  80102b:	85 d2                	test   %edx,%edx
  80102d:	7e 33                	jle    801062 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80102f:	8b 45 14             	mov    0x14(%ebp),%eax
  801032:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801036:	8b 45 10             	mov    0x10(%ebp),%eax
  801039:	89 44 24 08          	mov    %eax,0x8(%esp)
  80103d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801040:	89 44 24 04          	mov    %eax,0x4(%esp)
  801044:	c7 04 24 1c 0c 80 00 	movl   $0x800c1c,(%esp)
  80104b:	e8 0e fc ff ff       	call   800c5e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801050:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801053:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801056:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801059:	eb 0c                	jmp    801067 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80105b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801060:	eb 05                	jmp    801067 <vsnprintf+0x5d>
  801062:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801067:	c9                   	leave  
  801068:	c3                   	ret    

00801069 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80106f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801072:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801076:	8b 45 10             	mov    0x10(%ebp),%eax
  801079:	89 44 24 08          	mov    %eax,0x8(%esp)
  80107d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801080:	89 44 24 04          	mov    %eax,0x4(%esp)
  801084:	8b 45 08             	mov    0x8(%ebp),%eax
  801087:	89 04 24             	mov    %eax,(%esp)
  80108a:	e8 7b ff ff ff       	call   80100a <vsnprintf>
	va_end(ap);

	return rc;
}
  80108f:	c9                   	leave  
  801090:	c3                   	ret    
  801091:	00 00                	add    %al,(%eax)
	...

00801094 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	57                   	push   %edi
  801098:	56                   	push   %esi
  801099:	53                   	push   %ebx
  80109a:	83 ec 1c             	sub    $0x1c,%esp
  80109d:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	74 18                	je     8010bc <readline+0x28>
		fprintf(1, "%s", prompt);
  8010a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a8:	c7 44 24 04 84 36 80 	movl   $0x803684,0x4(%esp)
  8010af:	00 
  8010b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8010b7:	e8 fc 15 00 00       	call   8026b8 <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  8010bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c3:	e8 49 f8 ff ff       	call   800911 <iscons>
  8010c8:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8010ca:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8010cf:	e8 07 f8 ff ff       	call   8008db <getchar>
  8010d4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	79 20                	jns    8010fa <readline+0x66>
			if (c != -E_EOF)
  8010da:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8010dd:	0f 84 82 00 00 00    	je     801165 <readline+0xd1>
				cprintf("read error: %e\n", c);
  8010e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e7:	c7 04 24 5f 3a 80 00 	movl   $0x803a5f,(%esp)
  8010ee:	e8 09 fa ff ff       	call   800afc <cprintf>
			return NULL;
  8010f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f8:	eb 70                	jmp    80116a <readline+0xd6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010fa:	83 f8 08             	cmp    $0x8,%eax
  8010fd:	74 05                	je     801104 <readline+0x70>
  8010ff:	83 f8 7f             	cmp    $0x7f,%eax
  801102:	75 17                	jne    80111b <readline+0x87>
  801104:	85 f6                	test   %esi,%esi
  801106:	7e 13                	jle    80111b <readline+0x87>
			if (echoing)
  801108:	85 ff                	test   %edi,%edi
  80110a:	74 0c                	je     801118 <readline+0x84>
				cputchar('\b');
  80110c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801113:	e8 a2 f7 ff ff       	call   8008ba <cputchar>
			i--;
  801118:	4e                   	dec    %esi
  801119:	eb b4                	jmp    8010cf <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  80111b:	83 fb 1f             	cmp    $0x1f,%ebx
  80111e:	7e 1d                	jle    80113d <readline+0xa9>
  801120:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801126:	7f 15                	jg     80113d <readline+0xa9>
			if (echoing)
  801128:	85 ff                	test   %edi,%edi
  80112a:	74 08                	je     801134 <readline+0xa0>
				cputchar(c);
  80112c:	89 1c 24             	mov    %ebx,(%esp)
  80112f:	e8 86 f7 ff ff       	call   8008ba <cputchar>
			buf[i++] = c;
  801134:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  80113a:	46                   	inc    %esi
  80113b:	eb 92                	jmp    8010cf <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  80113d:	83 fb 0a             	cmp    $0xa,%ebx
  801140:	74 05                	je     801147 <readline+0xb3>
  801142:	83 fb 0d             	cmp    $0xd,%ebx
  801145:	75 88                	jne    8010cf <readline+0x3b>
			if (echoing)
  801147:	85 ff                	test   %edi,%edi
  801149:	74 0c                	je     801157 <readline+0xc3>
				cputchar('\n');
  80114b:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801152:	e8 63 f7 ff ff       	call   8008ba <cputchar>
			buf[i] = 0;
  801157:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  80115e:	b8 20 50 80 00       	mov    $0x805020,%eax
  801163:	eb 05                	jmp    80116a <readline+0xd6>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801165:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  80116a:	83 c4 1c             	add    $0x1c,%esp
  80116d:	5b                   	pop    %ebx
  80116e:	5e                   	pop    %esi
  80116f:	5f                   	pop    %edi
  801170:	5d                   	pop    %ebp
  801171:	c3                   	ret    
	...

00801174 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80117a:	b8 00 00 00 00       	mov    $0x0,%eax
  80117f:	eb 01                	jmp    801182 <strlen+0xe>
		n++;
  801181:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801182:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801186:	75 f9                	jne    801181 <strlen+0xd>
		n++;
	return n;
}
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    

0080118a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801190:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801193:	b8 00 00 00 00       	mov    $0x0,%eax
  801198:	eb 01                	jmp    80119b <strnlen+0x11>
		n++;
  80119a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80119b:	39 d0                	cmp    %edx,%eax
  80119d:	74 06                	je     8011a5 <strnlen+0x1b>
  80119f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8011a3:	75 f5                	jne    80119a <strnlen+0x10>
		n++;
	return n;
}
  8011a5:	5d                   	pop    %ebp
  8011a6:	c3                   	ret    

008011a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	53                   	push   %ebx
  8011ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8011b9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8011bc:	42                   	inc    %edx
  8011bd:	84 c9                	test   %cl,%cl
  8011bf:	75 f5                	jne    8011b6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8011c1:	5b                   	pop    %ebx
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	53                   	push   %ebx
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011ce:	89 1c 24             	mov    %ebx,(%esp)
  8011d1:	e8 9e ff ff ff       	call   801174 <strlen>
	strcpy(dst + len, src);
  8011d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011dd:	01 d8                	add    %ebx,%eax
  8011df:	89 04 24             	mov    %eax,(%esp)
  8011e2:	e8 c0 ff ff ff       	call   8011a7 <strcpy>
	return dst;
}
  8011e7:	89 d8                	mov    %ebx,%eax
  8011e9:	83 c4 08             	add    $0x8,%esp
  8011ec:	5b                   	pop    %ebx
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    

008011ef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	56                   	push   %esi
  8011f3:	53                   	push   %ebx
  8011f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011fa:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801202:	eb 0c                	jmp    801210 <strncpy+0x21>
		*dst++ = *src;
  801204:	8a 1a                	mov    (%edx),%bl
  801206:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801209:	80 3a 01             	cmpb   $0x1,(%edx)
  80120c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80120f:	41                   	inc    %ecx
  801210:	39 f1                	cmp    %esi,%ecx
  801212:	75 f0                	jne    801204 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801214:	5b                   	pop    %ebx
  801215:	5e                   	pop    %esi
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    

00801218 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	56                   	push   %esi
  80121c:	53                   	push   %ebx
  80121d:	8b 75 08             	mov    0x8(%ebp),%esi
  801220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801223:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801226:	85 d2                	test   %edx,%edx
  801228:	75 0a                	jne    801234 <strlcpy+0x1c>
  80122a:	89 f0                	mov    %esi,%eax
  80122c:	eb 1a                	jmp    801248 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80122e:	88 18                	mov    %bl,(%eax)
  801230:	40                   	inc    %eax
  801231:	41                   	inc    %ecx
  801232:	eb 02                	jmp    801236 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801234:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801236:	4a                   	dec    %edx
  801237:	74 0a                	je     801243 <strlcpy+0x2b>
  801239:	8a 19                	mov    (%ecx),%bl
  80123b:	84 db                	test   %bl,%bl
  80123d:	75 ef                	jne    80122e <strlcpy+0x16>
  80123f:	89 c2                	mov    %eax,%edx
  801241:	eb 02                	jmp    801245 <strlcpy+0x2d>
  801243:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801245:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801248:	29 f0                	sub    %esi,%eax
}
  80124a:	5b                   	pop    %ebx
  80124b:	5e                   	pop    %esi
  80124c:	5d                   	pop    %ebp
  80124d:	c3                   	ret    

0080124e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801254:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801257:	eb 02                	jmp    80125b <strcmp+0xd>
		p++, q++;
  801259:	41                   	inc    %ecx
  80125a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80125b:	8a 01                	mov    (%ecx),%al
  80125d:	84 c0                	test   %al,%al
  80125f:	74 04                	je     801265 <strcmp+0x17>
  801261:	3a 02                	cmp    (%edx),%al
  801263:	74 f4                	je     801259 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801265:	0f b6 c0             	movzbl %al,%eax
  801268:	0f b6 12             	movzbl (%edx),%edx
  80126b:	29 d0                	sub    %edx,%eax
}
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    

0080126f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	53                   	push   %ebx
  801273:	8b 45 08             	mov    0x8(%ebp),%eax
  801276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801279:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80127c:	eb 03                	jmp    801281 <strncmp+0x12>
		n--, p++, q++;
  80127e:	4a                   	dec    %edx
  80127f:	40                   	inc    %eax
  801280:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801281:	85 d2                	test   %edx,%edx
  801283:	74 14                	je     801299 <strncmp+0x2a>
  801285:	8a 18                	mov    (%eax),%bl
  801287:	84 db                	test   %bl,%bl
  801289:	74 04                	je     80128f <strncmp+0x20>
  80128b:	3a 19                	cmp    (%ecx),%bl
  80128d:	74 ef                	je     80127e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80128f:	0f b6 00             	movzbl (%eax),%eax
  801292:	0f b6 11             	movzbl (%ecx),%edx
  801295:	29 d0                	sub    %edx,%eax
  801297:	eb 05                	jmp    80129e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801299:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80129e:	5b                   	pop    %ebx
  80129f:	5d                   	pop    %ebp
  8012a0:	c3                   	ret    

008012a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8012aa:	eb 05                	jmp    8012b1 <strchr+0x10>
		if (*s == c)
  8012ac:	38 ca                	cmp    %cl,%dl
  8012ae:	74 0c                	je     8012bc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012b0:	40                   	inc    %eax
  8012b1:	8a 10                	mov    (%eax),%dl
  8012b3:	84 d2                	test   %dl,%dl
  8012b5:	75 f5                	jne    8012ac <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8012b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012bc:	5d                   	pop    %ebp
  8012bd:	c3                   	ret    

008012be <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8012c7:	eb 05                	jmp    8012ce <strfind+0x10>
		if (*s == c)
  8012c9:	38 ca                	cmp    %cl,%dl
  8012cb:	74 07                	je     8012d4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8012cd:	40                   	inc    %eax
  8012ce:	8a 10                	mov    (%eax),%dl
  8012d0:	84 d2                	test   %dl,%dl
  8012d2:	75 f5                	jne    8012c9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    

008012d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	57                   	push   %edi
  8012da:	56                   	push   %esi
  8012db:	53                   	push   %ebx
  8012dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012e5:	85 c9                	test   %ecx,%ecx
  8012e7:	74 30                	je     801319 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012ef:	75 25                	jne    801316 <memset+0x40>
  8012f1:	f6 c1 03             	test   $0x3,%cl
  8012f4:	75 20                	jne    801316 <memset+0x40>
		c &= 0xFF;
  8012f6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8012f9:	89 d3                	mov    %edx,%ebx
  8012fb:	c1 e3 08             	shl    $0x8,%ebx
  8012fe:	89 d6                	mov    %edx,%esi
  801300:	c1 e6 18             	shl    $0x18,%esi
  801303:	89 d0                	mov    %edx,%eax
  801305:	c1 e0 10             	shl    $0x10,%eax
  801308:	09 f0                	or     %esi,%eax
  80130a:	09 d0                	or     %edx,%eax
  80130c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80130e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801311:	fc                   	cld    
  801312:	f3 ab                	rep stos %eax,%es:(%edi)
  801314:	eb 03                	jmp    801319 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801316:	fc                   	cld    
  801317:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801319:	89 f8                	mov    %edi,%eax
  80131b:	5b                   	pop    %ebx
  80131c:	5e                   	pop    %esi
  80131d:	5f                   	pop    %edi
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    

00801320 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	57                   	push   %edi
  801324:	56                   	push   %esi
  801325:	8b 45 08             	mov    0x8(%ebp),%eax
  801328:	8b 75 0c             	mov    0xc(%ebp),%esi
  80132b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80132e:	39 c6                	cmp    %eax,%esi
  801330:	73 34                	jae    801366 <memmove+0x46>
  801332:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801335:	39 d0                	cmp    %edx,%eax
  801337:	73 2d                	jae    801366 <memmove+0x46>
		s += n;
		d += n;
  801339:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80133c:	f6 c2 03             	test   $0x3,%dl
  80133f:	75 1b                	jne    80135c <memmove+0x3c>
  801341:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801347:	75 13                	jne    80135c <memmove+0x3c>
  801349:	f6 c1 03             	test   $0x3,%cl
  80134c:	75 0e                	jne    80135c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80134e:	83 ef 04             	sub    $0x4,%edi
  801351:	8d 72 fc             	lea    -0x4(%edx),%esi
  801354:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801357:	fd                   	std    
  801358:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80135a:	eb 07                	jmp    801363 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80135c:	4f                   	dec    %edi
  80135d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801360:	fd                   	std    
  801361:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801363:	fc                   	cld    
  801364:	eb 20                	jmp    801386 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801366:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80136c:	75 13                	jne    801381 <memmove+0x61>
  80136e:	a8 03                	test   $0x3,%al
  801370:	75 0f                	jne    801381 <memmove+0x61>
  801372:	f6 c1 03             	test   $0x3,%cl
  801375:	75 0a                	jne    801381 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801377:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80137a:	89 c7                	mov    %eax,%edi
  80137c:	fc                   	cld    
  80137d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80137f:	eb 05                	jmp    801386 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801381:	89 c7                	mov    %eax,%edi
  801383:	fc                   	cld    
  801384:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801386:	5e                   	pop    %esi
  801387:	5f                   	pop    %edi
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    

0080138a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801390:	8b 45 10             	mov    0x10(%ebp),%eax
  801393:	89 44 24 08          	mov    %eax,0x8(%esp)
  801397:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139e:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a1:	89 04 24             	mov    %eax,(%esp)
  8013a4:	e8 77 ff ff ff       	call   801320 <memmove>
}
  8013a9:	c9                   	leave  
  8013aa:	c3                   	ret    

008013ab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	57                   	push   %edi
  8013af:	56                   	push   %esi
  8013b0:	53                   	push   %ebx
  8013b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bf:	eb 16                	jmp    8013d7 <memcmp+0x2c>
		if (*s1 != *s2)
  8013c1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8013c4:	42                   	inc    %edx
  8013c5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8013c9:	38 c8                	cmp    %cl,%al
  8013cb:	74 0a                	je     8013d7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8013cd:	0f b6 c0             	movzbl %al,%eax
  8013d0:	0f b6 c9             	movzbl %cl,%ecx
  8013d3:	29 c8                	sub    %ecx,%eax
  8013d5:	eb 09                	jmp    8013e0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013d7:	39 da                	cmp    %ebx,%edx
  8013d9:	75 e6                	jne    8013c1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	5f                   	pop    %edi
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    

008013e5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8013ee:	89 c2                	mov    %eax,%edx
  8013f0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8013f3:	eb 05                	jmp    8013fa <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013f5:	38 08                	cmp    %cl,(%eax)
  8013f7:	74 05                	je     8013fe <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013f9:	40                   	inc    %eax
  8013fa:	39 d0                	cmp    %edx,%eax
  8013fc:	72 f7                	jb     8013f5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013fe:	5d                   	pop    %ebp
  8013ff:	c3                   	ret    

00801400 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	57                   	push   %edi
  801404:	56                   	push   %esi
  801405:	53                   	push   %ebx
  801406:	8b 55 08             	mov    0x8(%ebp),%edx
  801409:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80140c:	eb 01                	jmp    80140f <strtol+0xf>
		s++;
  80140e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80140f:	8a 02                	mov    (%edx),%al
  801411:	3c 20                	cmp    $0x20,%al
  801413:	74 f9                	je     80140e <strtol+0xe>
  801415:	3c 09                	cmp    $0x9,%al
  801417:	74 f5                	je     80140e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801419:	3c 2b                	cmp    $0x2b,%al
  80141b:	75 08                	jne    801425 <strtol+0x25>
		s++;
  80141d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80141e:	bf 00 00 00 00       	mov    $0x0,%edi
  801423:	eb 13                	jmp    801438 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801425:	3c 2d                	cmp    $0x2d,%al
  801427:	75 0a                	jne    801433 <strtol+0x33>
		s++, neg = 1;
  801429:	8d 52 01             	lea    0x1(%edx),%edx
  80142c:	bf 01 00 00 00       	mov    $0x1,%edi
  801431:	eb 05                	jmp    801438 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801433:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801438:	85 db                	test   %ebx,%ebx
  80143a:	74 05                	je     801441 <strtol+0x41>
  80143c:	83 fb 10             	cmp    $0x10,%ebx
  80143f:	75 28                	jne    801469 <strtol+0x69>
  801441:	8a 02                	mov    (%edx),%al
  801443:	3c 30                	cmp    $0x30,%al
  801445:	75 10                	jne    801457 <strtol+0x57>
  801447:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80144b:	75 0a                	jne    801457 <strtol+0x57>
		s += 2, base = 16;
  80144d:	83 c2 02             	add    $0x2,%edx
  801450:	bb 10 00 00 00       	mov    $0x10,%ebx
  801455:	eb 12                	jmp    801469 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801457:	85 db                	test   %ebx,%ebx
  801459:	75 0e                	jne    801469 <strtol+0x69>
  80145b:	3c 30                	cmp    $0x30,%al
  80145d:	75 05                	jne    801464 <strtol+0x64>
		s++, base = 8;
  80145f:	42                   	inc    %edx
  801460:	b3 08                	mov    $0x8,%bl
  801462:	eb 05                	jmp    801469 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801464:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801469:	b8 00 00 00 00       	mov    $0x0,%eax
  80146e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801470:	8a 0a                	mov    (%edx),%cl
  801472:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801475:	80 fb 09             	cmp    $0x9,%bl
  801478:	77 08                	ja     801482 <strtol+0x82>
			dig = *s - '0';
  80147a:	0f be c9             	movsbl %cl,%ecx
  80147d:	83 e9 30             	sub    $0x30,%ecx
  801480:	eb 1e                	jmp    8014a0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801482:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801485:	80 fb 19             	cmp    $0x19,%bl
  801488:	77 08                	ja     801492 <strtol+0x92>
			dig = *s - 'a' + 10;
  80148a:	0f be c9             	movsbl %cl,%ecx
  80148d:	83 e9 57             	sub    $0x57,%ecx
  801490:	eb 0e                	jmp    8014a0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801492:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801495:	80 fb 19             	cmp    $0x19,%bl
  801498:	77 12                	ja     8014ac <strtol+0xac>
			dig = *s - 'A' + 10;
  80149a:	0f be c9             	movsbl %cl,%ecx
  80149d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8014a0:	39 f1                	cmp    %esi,%ecx
  8014a2:	7d 0c                	jge    8014b0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8014a4:	42                   	inc    %edx
  8014a5:	0f af c6             	imul   %esi,%eax
  8014a8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8014aa:	eb c4                	jmp    801470 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8014ac:	89 c1                	mov    %eax,%ecx
  8014ae:	eb 02                	jmp    8014b2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8014b0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8014b2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014b6:	74 05                	je     8014bd <strtol+0xbd>
		*endptr = (char *) s;
  8014b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014bb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8014bd:	85 ff                	test   %edi,%edi
  8014bf:	74 04                	je     8014c5 <strtol+0xc5>
  8014c1:	89 c8                	mov    %ecx,%eax
  8014c3:	f7 d8                	neg    %eax
}
  8014c5:	5b                   	pop    %ebx
  8014c6:	5e                   	pop    %esi
  8014c7:	5f                   	pop    %edi
  8014c8:	5d                   	pop    %ebp
  8014c9:	c3                   	ret    
	...

008014cc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	57                   	push   %edi
  8014d0:	56                   	push   %esi
  8014d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014da:	8b 55 08             	mov    0x8(%ebp),%edx
  8014dd:	89 c3                	mov    %eax,%ebx
  8014df:	89 c7                	mov    %eax,%edi
  8014e1:	89 c6                	mov    %eax,%esi
  8014e3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014e5:	5b                   	pop    %ebx
  8014e6:	5e                   	pop    %esi
  8014e7:	5f                   	pop    %edi
  8014e8:	5d                   	pop    %ebp
  8014e9:	c3                   	ret    

008014ea <sys_cgetc>:

int
sys_cgetc(void)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	57                   	push   %edi
  8014ee:	56                   	push   %esi
  8014ef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8014fa:	89 d1                	mov    %edx,%ecx
  8014fc:	89 d3                	mov    %edx,%ebx
  8014fe:	89 d7                	mov    %edx,%edi
  801500:	89 d6                	mov    %edx,%esi
  801502:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801504:	5b                   	pop    %ebx
  801505:	5e                   	pop    %esi
  801506:	5f                   	pop    %edi
  801507:	5d                   	pop    %ebp
  801508:	c3                   	ret    

00801509 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	57                   	push   %edi
  80150d:	56                   	push   %esi
  80150e:	53                   	push   %ebx
  80150f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801512:	b9 00 00 00 00       	mov    $0x0,%ecx
  801517:	b8 03 00 00 00       	mov    $0x3,%eax
  80151c:	8b 55 08             	mov    0x8(%ebp),%edx
  80151f:	89 cb                	mov    %ecx,%ebx
  801521:	89 cf                	mov    %ecx,%edi
  801523:	89 ce                	mov    %ecx,%esi
  801525:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801527:	85 c0                	test   %eax,%eax
  801529:	7e 28                	jle    801553 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80152b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80152f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801536:	00 
  801537:	c7 44 24 08 6f 3a 80 	movl   $0x803a6f,0x8(%esp)
  80153e:	00 
  80153f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801546:	00 
  801547:	c7 04 24 8c 3a 80 00 	movl   $0x803a8c,(%esp)
  80154e:	e8 b1 f4 ff ff       	call   800a04 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801553:	83 c4 2c             	add    $0x2c,%esp
  801556:	5b                   	pop    %ebx
  801557:	5e                   	pop    %esi
  801558:	5f                   	pop    %edi
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    

0080155b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	57                   	push   %edi
  80155f:	56                   	push   %esi
  801560:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801561:	ba 00 00 00 00       	mov    $0x0,%edx
  801566:	b8 02 00 00 00       	mov    $0x2,%eax
  80156b:	89 d1                	mov    %edx,%ecx
  80156d:	89 d3                	mov    %edx,%ebx
  80156f:	89 d7                	mov    %edx,%edi
  801571:	89 d6                	mov    %edx,%esi
  801573:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801575:	5b                   	pop    %ebx
  801576:	5e                   	pop    %esi
  801577:	5f                   	pop    %edi
  801578:	5d                   	pop    %ebp
  801579:	c3                   	ret    

0080157a <sys_yield>:

void
sys_yield(void)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	57                   	push   %edi
  80157e:	56                   	push   %esi
  80157f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801580:	ba 00 00 00 00       	mov    $0x0,%edx
  801585:	b8 0b 00 00 00       	mov    $0xb,%eax
  80158a:	89 d1                	mov    %edx,%ecx
  80158c:	89 d3                	mov    %edx,%ebx
  80158e:	89 d7                	mov    %edx,%edi
  801590:	89 d6                	mov    %edx,%esi
  801592:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801594:	5b                   	pop    %ebx
  801595:	5e                   	pop    %esi
  801596:	5f                   	pop    %edi
  801597:	5d                   	pop    %ebp
  801598:	c3                   	ret    

00801599 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	57                   	push   %edi
  80159d:	56                   	push   %esi
  80159e:	53                   	push   %ebx
  80159f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015a2:	be 00 00 00 00       	mov    $0x0,%esi
  8015a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8015ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b5:	89 f7                	mov    %esi,%edi
  8015b7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	7e 28                	jle    8015e5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015c1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8015c8:	00 
  8015c9:	c7 44 24 08 6f 3a 80 	movl   $0x803a6f,0x8(%esp)
  8015d0:	00 
  8015d1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015d8:	00 
  8015d9:	c7 04 24 8c 3a 80 00 	movl   $0x803a8c,(%esp)
  8015e0:	e8 1f f4 ff ff       	call   800a04 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015e5:	83 c4 2c             	add    $0x2c,%esp
  8015e8:	5b                   	pop    %ebx
  8015e9:	5e                   	pop    %esi
  8015ea:	5f                   	pop    %edi
  8015eb:	5d                   	pop    %ebp
  8015ec:	c3                   	ret    

008015ed <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	57                   	push   %edi
  8015f1:	56                   	push   %esi
  8015f2:	53                   	push   %ebx
  8015f3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8015fb:	8b 75 18             	mov    0x18(%ebp),%esi
  8015fe:	8b 7d 14             	mov    0x14(%ebp),%edi
  801601:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801604:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801607:	8b 55 08             	mov    0x8(%ebp),%edx
  80160a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80160c:	85 c0                	test   %eax,%eax
  80160e:	7e 28                	jle    801638 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801610:	89 44 24 10          	mov    %eax,0x10(%esp)
  801614:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80161b:	00 
  80161c:	c7 44 24 08 6f 3a 80 	movl   $0x803a6f,0x8(%esp)
  801623:	00 
  801624:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80162b:	00 
  80162c:	c7 04 24 8c 3a 80 00 	movl   $0x803a8c,(%esp)
  801633:	e8 cc f3 ff ff       	call   800a04 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801638:	83 c4 2c             	add    $0x2c,%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	5f                   	pop    %edi
  80163e:	5d                   	pop    %ebp
  80163f:	c3                   	ret    

00801640 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	57                   	push   %edi
  801644:	56                   	push   %esi
  801645:	53                   	push   %ebx
  801646:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801649:	bb 00 00 00 00       	mov    $0x0,%ebx
  80164e:	b8 06 00 00 00       	mov    $0x6,%eax
  801653:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801656:	8b 55 08             	mov    0x8(%ebp),%edx
  801659:	89 df                	mov    %ebx,%edi
  80165b:	89 de                	mov    %ebx,%esi
  80165d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80165f:	85 c0                	test   %eax,%eax
  801661:	7e 28                	jle    80168b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801663:	89 44 24 10          	mov    %eax,0x10(%esp)
  801667:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80166e:	00 
  80166f:	c7 44 24 08 6f 3a 80 	movl   $0x803a6f,0x8(%esp)
  801676:	00 
  801677:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80167e:	00 
  80167f:	c7 04 24 8c 3a 80 00 	movl   $0x803a8c,(%esp)
  801686:	e8 79 f3 ff ff       	call   800a04 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80168b:	83 c4 2c             	add    $0x2c,%esp
  80168e:	5b                   	pop    %ebx
  80168f:	5e                   	pop    %esi
  801690:	5f                   	pop    %edi
  801691:	5d                   	pop    %ebp
  801692:	c3                   	ret    

00801693 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	57                   	push   %edi
  801697:	56                   	push   %esi
  801698:	53                   	push   %ebx
  801699:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80169c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016a1:	b8 08 00 00 00       	mov    $0x8,%eax
  8016a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8016ac:	89 df                	mov    %ebx,%edi
  8016ae:	89 de                	mov    %ebx,%esi
  8016b0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	7e 28                	jle    8016de <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016ba:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8016c1:	00 
  8016c2:	c7 44 24 08 6f 3a 80 	movl   $0x803a6f,0x8(%esp)
  8016c9:	00 
  8016ca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016d1:	00 
  8016d2:	c7 04 24 8c 3a 80 00 	movl   $0x803a8c,(%esp)
  8016d9:	e8 26 f3 ff ff       	call   800a04 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8016de:	83 c4 2c             	add    $0x2c,%esp
  8016e1:	5b                   	pop    %ebx
  8016e2:	5e                   	pop    %esi
  8016e3:	5f                   	pop    %edi
  8016e4:	5d                   	pop    %ebp
  8016e5:	c3                   	ret    

008016e6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	57                   	push   %edi
  8016ea:	56                   	push   %esi
  8016eb:	53                   	push   %ebx
  8016ec:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016f4:	b8 09 00 00 00       	mov    $0x9,%eax
  8016f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8016ff:	89 df                	mov    %ebx,%edi
  801701:	89 de                	mov    %ebx,%esi
  801703:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801705:	85 c0                	test   %eax,%eax
  801707:	7e 28                	jle    801731 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801709:	89 44 24 10          	mov    %eax,0x10(%esp)
  80170d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801714:	00 
  801715:	c7 44 24 08 6f 3a 80 	movl   $0x803a6f,0x8(%esp)
  80171c:	00 
  80171d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801724:	00 
  801725:	c7 04 24 8c 3a 80 00 	movl   $0x803a8c,(%esp)
  80172c:	e8 d3 f2 ff ff       	call   800a04 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801731:	83 c4 2c             	add    $0x2c,%esp
  801734:	5b                   	pop    %ebx
  801735:	5e                   	pop    %esi
  801736:	5f                   	pop    %edi
  801737:	5d                   	pop    %ebp
  801738:	c3                   	ret    

00801739 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	57                   	push   %edi
  80173d:	56                   	push   %esi
  80173e:	53                   	push   %ebx
  80173f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801742:	bb 00 00 00 00       	mov    $0x0,%ebx
  801747:	b8 0a 00 00 00       	mov    $0xa,%eax
  80174c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174f:	8b 55 08             	mov    0x8(%ebp),%edx
  801752:	89 df                	mov    %ebx,%edi
  801754:	89 de                	mov    %ebx,%esi
  801756:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801758:	85 c0                	test   %eax,%eax
  80175a:	7e 28                	jle    801784 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80175c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801760:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801767:	00 
  801768:	c7 44 24 08 6f 3a 80 	movl   $0x803a6f,0x8(%esp)
  80176f:	00 
  801770:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801777:	00 
  801778:	c7 04 24 8c 3a 80 00 	movl   $0x803a8c,(%esp)
  80177f:	e8 80 f2 ff ff       	call   800a04 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801784:	83 c4 2c             	add    $0x2c,%esp
  801787:	5b                   	pop    %ebx
  801788:	5e                   	pop    %esi
  801789:	5f                   	pop    %edi
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	57                   	push   %edi
  801790:	56                   	push   %esi
  801791:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801792:	be 00 00 00 00       	mov    $0x0,%esi
  801797:	b8 0c 00 00 00       	mov    $0xc,%eax
  80179c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80179f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8017a8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8017aa:	5b                   	pop    %ebx
  8017ab:	5e                   	pop    %esi
  8017ac:	5f                   	pop    %edi
  8017ad:	5d                   	pop    %ebp
  8017ae:	c3                   	ret    

008017af <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	57                   	push   %edi
  8017b3:	56                   	push   %esi
  8017b4:	53                   	push   %ebx
  8017b5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017bd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8017c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8017c5:	89 cb                	mov    %ecx,%ebx
  8017c7:	89 cf                	mov    %ecx,%edi
  8017c9:	89 ce                	mov    %ecx,%esi
  8017cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	7e 28                	jle    8017f9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017d5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8017dc:	00 
  8017dd:	c7 44 24 08 6f 3a 80 	movl   $0x803a6f,0x8(%esp)
  8017e4:	00 
  8017e5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8017ec:	00 
  8017ed:	c7 04 24 8c 3a 80 00 	movl   $0x803a8c,(%esp)
  8017f4:	e8 0b f2 ff ff       	call   800a04 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8017f9:	83 c4 2c             	add    $0x2c,%esp
  8017fc:	5b                   	pop    %ebx
  8017fd:	5e                   	pop    %esi
  8017fe:	5f                   	pop    %edi
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    
  801801:	00 00                	add    %al,(%eax)
	...

00801804 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	53                   	push   %ebx
  801808:	83 ec 24             	sub    $0x24,%esp
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80180e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  801810:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801814:	75 20                	jne    801836 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  801816:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80181a:	c7 44 24 08 9c 3a 80 	movl   $0x803a9c,0x8(%esp)
  801821:	00 
  801822:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  801829:	00 
  80182a:	c7 04 24 1b 3b 80 00 	movl   $0x803b1b,(%esp)
  801831:	e8 ce f1 ff ff       	call   800a04 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  801836:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  80183c:	89 d8                	mov    %ebx,%eax
  80183e:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  801841:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801848:	f6 c4 08             	test   $0x8,%ah
  80184b:	75 1c                	jne    801869 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  80184d:	c7 44 24 08 cc 3a 80 	movl   $0x803acc,0x8(%esp)
  801854:	00 
  801855:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  80185c:	00 
  80185d:	c7 04 24 1b 3b 80 00 	movl   $0x803b1b,(%esp)
  801864:	e8 9b f1 ff ff       	call   800a04 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  801869:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801870:	00 
  801871:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801878:	00 
  801879:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801880:	e8 14 fd ff ff       	call   801599 <sys_page_alloc>
  801885:	85 c0                	test   %eax,%eax
  801887:	79 20                	jns    8018a9 <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  801889:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80188d:	c7 44 24 08 26 3b 80 	movl   $0x803b26,0x8(%esp)
  801894:	00 
  801895:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80189c:	00 
  80189d:	c7 04 24 1b 3b 80 00 	movl   $0x803b1b,(%esp)
  8018a4:	e8 5b f1 ff ff       	call   800a04 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  8018a9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8018b0:	00 
  8018b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018b5:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8018bc:	e8 5f fa ff ff       	call   801320 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  8018c1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8018c8:	00 
  8018c9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8018cd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018d4:	00 
  8018d5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8018dc:	00 
  8018dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e4:	e8 04 fd ff ff       	call   8015ed <sys_page_map>
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	79 20                	jns    80190d <pgfault+0x109>
		panic("sys_page_map: %e", r);
  8018ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018f1:	c7 44 24 08 39 3b 80 	movl   $0x803b39,0x8(%esp)
  8018f8:	00 
  8018f9:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801900:	00 
  801901:	c7 04 24 1b 3b 80 00 	movl   $0x803b1b,(%esp)
  801908:	e8 f7 f0 ff ff       	call   800a04 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  80190d:	83 c4 24             	add    $0x24,%esp
  801910:	5b                   	pop    %ebx
  801911:	5d                   	pop    %ebp
  801912:	c3                   	ret    

00801913 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	57                   	push   %edi
  801917:	56                   	push   %esi
  801918:	53                   	push   %ebx
  801919:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  80191c:	c7 04 24 04 18 80 00 	movl   $0x801804,(%esp)
  801923:	e8 84 17 00 00       	call   8030ac <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801928:	ba 07 00 00 00       	mov    $0x7,%edx
  80192d:	89 d0                	mov    %edx,%eax
  80192f:	cd 30                	int    $0x30
  801931:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801934:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  801937:	85 c0                	test   %eax,%eax
  801939:	79 20                	jns    80195b <fork+0x48>
		panic("sys_exofork: %e", envid);
  80193b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80193f:	c7 44 24 08 4a 3b 80 	movl   $0x803b4a,0x8(%esp)
  801946:	00 
  801947:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  80194e:	00 
  80194f:	c7 04 24 1b 3b 80 00 	movl   $0x803b1b,(%esp)
  801956:	e8 a9 f0 ff ff       	call   800a04 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  80195b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80195f:	75 25                	jne    801986 <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  801961:	e8 f5 fb ff ff       	call   80155b <sys_getenvid>
  801966:	25 ff 03 00 00       	and    $0x3ff,%eax
  80196b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801972:	c1 e0 07             	shl    $0x7,%eax
  801975:	29 d0                	sub    %edx,%eax
  801977:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80197c:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  801981:	e9 58 02 00 00       	jmp    801bde <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  801986:	bf 00 00 00 00       	mov    $0x0,%edi
  80198b:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  801990:	89 f0                	mov    %esi,%eax
  801992:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801995:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80199c:	a8 01                	test   $0x1,%al
  80199e:	0f 84 7a 01 00 00    	je     801b1e <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  8019a4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8019ab:	a8 01                	test   $0x1,%al
  8019ad:	0f 84 6b 01 00 00    	je     801b1e <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  8019b3:	a1 24 54 80 00       	mov    0x805424,%eax
  8019b8:	8b 40 48             	mov    0x48(%eax),%eax
  8019bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  8019be:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8019c5:	f6 c4 04             	test   $0x4,%ah
  8019c8:	74 52                	je     801a1c <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8019ca:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8019d1:	25 07 0e 00 00       	and    $0xe07,%eax
  8019d6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8019da:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ec:	89 04 24             	mov    %eax,(%esp)
  8019ef:	e8 f9 fb ff ff       	call   8015ed <sys_page_map>
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	0f 89 22 01 00 00    	jns    801b1e <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8019fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a00:	c7 44 24 08 5a 3b 80 	movl   $0x803b5a,0x8(%esp)
  801a07:	00 
  801a08:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801a0f:	00 
  801a10:	c7 04 24 1b 3b 80 00 	movl   $0x803b1b,(%esp)
  801a17:	e8 e8 ef ff ff       	call   800a04 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801a1c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a23:	f6 c4 08             	test   $0x8,%ah
  801a26:	75 0f                	jne    801a37 <fork+0x124>
  801a28:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a2f:	a8 02                	test   $0x2,%al
  801a31:	0f 84 99 00 00 00    	je     801ad0 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  801a37:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a3e:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801a41:	83 f8 01             	cmp    $0x1,%eax
  801a44:	19 db                	sbb    %ebx,%ebx
  801a46:	83 e3 fc             	and    $0xfffffffc,%ebx
  801a49:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  801a4f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801a53:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a57:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a5e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a65:	89 04 24             	mov    %eax,(%esp)
  801a68:	e8 80 fb ff ff       	call   8015ed <sys_page_map>
  801a6d:	85 c0                	test   %eax,%eax
  801a6f:	79 20                	jns    801a91 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801a71:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a75:	c7 44 24 08 5a 3b 80 	movl   $0x803b5a,0x8(%esp)
  801a7c:	00 
  801a7d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801a84:	00 
  801a85:	c7 04 24 1b 3b 80 00 	movl   $0x803b1b,(%esp)
  801a8c:	e8 73 ef ff ff       	call   800a04 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801a91:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801a95:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aa0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801aa4:	89 04 24             	mov    %eax,(%esp)
  801aa7:	e8 41 fb ff ff       	call   8015ed <sys_page_map>
  801aac:	85 c0                	test   %eax,%eax
  801aae:	79 6e                	jns    801b1e <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801ab0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ab4:	c7 44 24 08 5a 3b 80 	movl   $0x803b5a,0x8(%esp)
  801abb:	00 
  801abc:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  801ac3:	00 
  801ac4:	c7 04 24 1b 3b 80 00 	movl   $0x803b1b,(%esp)
  801acb:	e8 34 ef ff ff       	call   800a04 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801ad0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801ad7:	25 07 0e 00 00       	and    $0xe07,%eax
  801adc:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ae0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ae4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ae7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aeb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801aef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801af2:	89 04 24             	mov    %eax,(%esp)
  801af5:	e8 f3 fa ff ff       	call   8015ed <sys_page_map>
  801afa:	85 c0                	test   %eax,%eax
  801afc:	79 20                	jns    801b1e <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801afe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b02:	c7 44 24 08 5a 3b 80 	movl   $0x803b5a,0x8(%esp)
  801b09:	00 
  801b0a:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801b11:	00 
  801b12:	c7 04 24 1b 3b 80 00 	movl   $0x803b1b,(%esp)
  801b19:	e8 e6 ee ff ff       	call   800a04 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  801b1e:	46                   	inc    %esi
  801b1f:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801b25:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801b2b:	0f 85 5f fe ff ff    	jne    801990 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  801b31:	c7 44 24 04 4c 31 80 	movl   $0x80314c,0x4(%esp)
  801b38:	00 
  801b39:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801b3c:	89 04 24             	mov    %eax,(%esp)
  801b3f:	e8 f5 fb ff ff       	call   801739 <sys_env_set_pgfault_upcall>
  801b44:	85 c0                	test   %eax,%eax
  801b46:	79 20                	jns    801b68 <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801b48:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b4c:	c7 44 24 08 fc 3a 80 	movl   $0x803afc,0x8(%esp)
  801b53:	00 
  801b54:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801b5b:	00 
  801b5c:	c7 04 24 1b 3b 80 00 	movl   $0x803b1b,(%esp)
  801b63:	e8 9c ee ff ff       	call   800a04 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  801b68:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b6f:	00 
  801b70:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801b77:	ee 
  801b78:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801b7b:	89 04 24             	mov    %eax,(%esp)
  801b7e:	e8 16 fa ff ff       	call   801599 <sys_page_alloc>
  801b83:	85 c0                	test   %eax,%eax
  801b85:	79 20                	jns    801ba7 <fork+0x294>
		panic("sys_page_alloc: %e", r);
  801b87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b8b:	c7 44 24 08 26 3b 80 	movl   $0x803b26,0x8(%esp)
  801b92:	00 
  801b93:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801b9a:	00 
  801b9b:	c7 04 24 1b 3b 80 00 	movl   $0x803b1b,(%esp)
  801ba2:	e8 5d ee ff ff       	call   800a04 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801ba7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801bae:	00 
  801baf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801bb2:	89 04 24             	mov    %eax,(%esp)
  801bb5:	e8 d9 fa ff ff       	call   801693 <sys_env_set_status>
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	79 20                	jns    801bde <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  801bbe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bc2:	c7 44 24 08 6c 3b 80 	movl   $0x803b6c,0x8(%esp)
  801bc9:	00 
  801bca:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801bd1:	00 
  801bd2:	c7 04 24 1b 3b 80 00 	movl   $0x803b1b,(%esp)
  801bd9:	e8 26 ee ff ff       	call   800a04 <_panic>
	}
	
	return envid;
}
  801bde:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801be1:	83 c4 3c             	add    $0x3c,%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5f                   	pop    %edi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <sfork>:

// Challenge!
int
sfork(void)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801bef:	c7 44 24 08 83 3b 80 	movl   $0x803b83,0x8(%esp)
  801bf6:	00 
  801bf7:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801bfe:	00 
  801bff:	c7 04 24 1b 3b 80 00 	movl   $0x803b1b,(%esp)
  801c06:	e8 f9 ed ff ff       	call   800a04 <_panic>
	...

00801c0c <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  801c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c15:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801c18:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801c1a:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801c1d:	83 3a 01             	cmpl   $0x1,(%edx)
  801c20:	7e 0b                	jle    801c2d <argstart+0x21>
  801c22:	85 c9                	test   %ecx,%ecx
  801c24:	75 0e                	jne    801c34 <argstart+0x28>
  801c26:	ba 00 00 00 00       	mov    $0x0,%edx
  801c2b:	eb 0c                	jmp    801c39 <argstart+0x2d>
  801c2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c32:	eb 05                	jmp    801c39 <argstart+0x2d>
  801c34:	ba 41 35 80 00       	mov    $0x803541,%edx
  801c39:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801c3c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <argnext>:

int
argnext(struct Argstate *args)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	53                   	push   %ebx
  801c49:	83 ec 14             	sub    $0x14,%esp
  801c4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801c4f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801c56:	8b 43 08             	mov    0x8(%ebx),%eax
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	74 6c                	je     801cc9 <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  801c5d:	80 38 00             	cmpb   $0x0,(%eax)
  801c60:	75 4d                	jne    801caf <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801c62:	8b 0b                	mov    (%ebx),%ecx
  801c64:	83 39 01             	cmpl   $0x1,(%ecx)
  801c67:	74 52                	je     801cbb <argnext+0x76>
		    || args->argv[1][0] != '-'
  801c69:	8b 53 04             	mov    0x4(%ebx),%edx
  801c6c:	8b 42 04             	mov    0x4(%edx),%eax
  801c6f:	80 38 2d             	cmpb   $0x2d,(%eax)
  801c72:	75 47                	jne    801cbb <argnext+0x76>
		    || args->argv[1][1] == '\0')
  801c74:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801c78:	74 41                	je     801cbb <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801c7a:	40                   	inc    %eax
  801c7b:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801c7e:	8b 01                	mov    (%ecx),%eax
  801c80:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801c87:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c8b:	8d 42 08             	lea    0x8(%edx),%eax
  801c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c92:	83 c2 04             	add    $0x4,%edx
  801c95:	89 14 24             	mov    %edx,(%esp)
  801c98:	e8 83 f6 ff ff       	call   801320 <memmove>
		(*args->argc)--;
  801c9d:	8b 03                	mov    (%ebx),%eax
  801c9f:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801ca1:	8b 43 08             	mov    0x8(%ebx),%eax
  801ca4:	80 38 2d             	cmpb   $0x2d,(%eax)
  801ca7:	75 06                	jne    801caf <argnext+0x6a>
  801ca9:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801cad:	74 0c                	je     801cbb <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801caf:	8b 53 08             	mov    0x8(%ebx),%edx
  801cb2:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801cb5:	42                   	inc    %edx
  801cb6:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801cb9:	eb 13                	jmp    801cce <argnext+0x89>

    endofargs:
	args->curarg = 0;
  801cbb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801cc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801cc7:	eb 05                	jmp    801cce <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801cc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801cce:	83 c4 14             	add    $0x14,%esp
  801cd1:	5b                   	pop    %ebx
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    

00801cd4 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	53                   	push   %ebx
  801cd8:	83 ec 14             	sub    $0x14,%esp
  801cdb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801cde:	8b 43 08             	mov    0x8(%ebx),%eax
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	74 59                	je     801d3e <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  801ce5:	80 38 00             	cmpb   $0x0,(%eax)
  801ce8:	74 0c                	je     801cf6 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801cea:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801ced:	c7 43 08 41 35 80 00 	movl   $0x803541,0x8(%ebx)
  801cf4:	eb 43                	jmp    801d39 <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  801cf6:	8b 03                	mov    (%ebx),%eax
  801cf8:	83 38 01             	cmpl   $0x1,(%eax)
  801cfb:	7e 2e                	jle    801d2b <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  801cfd:	8b 53 04             	mov    0x4(%ebx),%edx
  801d00:	8b 4a 04             	mov    0x4(%edx),%ecx
  801d03:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801d06:	8b 00                	mov    (%eax),%eax
  801d08:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801d0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d13:	8d 42 08             	lea    0x8(%edx),%eax
  801d16:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d1a:	83 c2 04             	add    $0x4,%edx
  801d1d:	89 14 24             	mov    %edx,(%esp)
  801d20:	e8 fb f5 ff ff       	call   801320 <memmove>
		(*args->argc)--;
  801d25:	8b 03                	mov    (%ebx),%eax
  801d27:	ff 08                	decl   (%eax)
  801d29:	eb 0e                	jmp    801d39 <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  801d2b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801d32:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801d39:	8b 43 0c             	mov    0xc(%ebx),%eax
  801d3c:	eb 05                	jmp    801d43 <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801d3e:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801d43:	83 c4 14             	add    $0x14,%esp
  801d46:	5b                   	pop    %ebx
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    

00801d49 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	83 ec 18             	sub    $0x18,%esp
  801d4f:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801d52:	8b 42 0c             	mov    0xc(%edx),%eax
  801d55:	85 c0                	test   %eax,%eax
  801d57:	75 08                	jne    801d61 <argvalue+0x18>
  801d59:	89 14 24             	mov    %edx,(%esp)
  801d5c:	e8 73 ff ff ff       	call   801cd4 <argnextvalue>
}
  801d61:	c9                   	leave  
  801d62:	c3                   	ret    
	...

00801d64 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801d64:	55                   	push   %ebp
  801d65:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801d67:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6a:	05 00 00 00 30       	add    $0x30000000,%eax
  801d6f:	c1 e8 0c             	shr    $0xc,%eax
}
  801d72:	5d                   	pop    %ebp
  801d73:	c3                   	ret    

00801d74 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7d:	89 04 24             	mov    %eax,(%esp)
  801d80:	e8 df ff ff ff       	call   801d64 <fd2num>
  801d85:	05 20 00 0d 00       	add    $0xd0020,%eax
  801d8a:	c1 e0 0c             	shl    $0xc,%eax
}
  801d8d:	c9                   	leave  
  801d8e:	c3                   	ret    

00801d8f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	53                   	push   %ebx
  801d93:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801d96:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801d9b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801d9d:	89 c2                	mov    %eax,%edx
  801d9f:	c1 ea 16             	shr    $0x16,%edx
  801da2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801da9:	f6 c2 01             	test   $0x1,%dl
  801dac:	74 11                	je     801dbf <fd_alloc+0x30>
  801dae:	89 c2                	mov    %eax,%edx
  801db0:	c1 ea 0c             	shr    $0xc,%edx
  801db3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801dba:	f6 c2 01             	test   $0x1,%dl
  801dbd:	75 09                	jne    801dc8 <fd_alloc+0x39>
			*fd_store = fd;
  801dbf:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801dc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc6:	eb 17                	jmp    801ddf <fd_alloc+0x50>
  801dc8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801dcd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801dd2:	75 c7                	jne    801d9b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801dd4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801dda:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801ddf:	5b                   	pop    %ebx
  801de0:	5d                   	pop    %ebp
  801de1:	c3                   	ret    

00801de2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801de8:	83 f8 1f             	cmp    $0x1f,%eax
  801deb:	77 36                	ja     801e23 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801ded:	05 00 00 0d 00       	add    $0xd0000,%eax
  801df2:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801df5:	89 c2                	mov    %eax,%edx
  801df7:	c1 ea 16             	shr    $0x16,%edx
  801dfa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e01:	f6 c2 01             	test   $0x1,%dl
  801e04:	74 24                	je     801e2a <fd_lookup+0x48>
  801e06:	89 c2                	mov    %eax,%edx
  801e08:	c1 ea 0c             	shr    $0xc,%edx
  801e0b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e12:	f6 c2 01             	test   $0x1,%dl
  801e15:	74 1a                	je     801e31 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801e17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e1a:	89 02                	mov    %eax,(%edx)
	return 0;
  801e1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e21:	eb 13                	jmp    801e36 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801e23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e28:	eb 0c                	jmp    801e36 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801e2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e2f:	eb 05                	jmp    801e36 <fd_lookup+0x54>
  801e31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801e36:	5d                   	pop    %ebp
  801e37:	c3                   	ret    

00801e38 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	53                   	push   %ebx
  801e3c:	83 ec 14             	sub    $0x14,%esp
  801e3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801e45:	ba 00 00 00 00       	mov    $0x0,%edx
  801e4a:	eb 0e                	jmp    801e5a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801e4c:	39 08                	cmp    %ecx,(%eax)
  801e4e:	75 09                	jne    801e59 <dev_lookup+0x21>
			*dev = devtab[i];
  801e50:	89 03                	mov    %eax,(%ebx)
			return 0;
  801e52:	b8 00 00 00 00       	mov    $0x0,%eax
  801e57:	eb 33                	jmp    801e8c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801e59:	42                   	inc    %edx
  801e5a:	8b 04 95 18 3c 80 00 	mov    0x803c18(,%edx,4),%eax
  801e61:	85 c0                	test   %eax,%eax
  801e63:	75 e7                	jne    801e4c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801e65:	a1 24 54 80 00       	mov    0x805424,%eax
  801e6a:	8b 40 48             	mov    0x48(%eax),%eax
  801e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e71:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e75:	c7 04 24 9c 3b 80 00 	movl   $0x803b9c,(%esp)
  801e7c:	e8 7b ec ff ff       	call   800afc <cprintf>
	*dev = 0;
  801e81:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801e87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801e8c:	83 c4 14             	add    $0x14,%esp
  801e8f:	5b                   	pop    %ebx
  801e90:	5d                   	pop    %ebp
  801e91:	c3                   	ret    

00801e92 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801e92:	55                   	push   %ebp
  801e93:	89 e5                	mov    %esp,%ebp
  801e95:	56                   	push   %esi
  801e96:	53                   	push   %ebx
  801e97:	83 ec 30             	sub    $0x30,%esp
  801e9a:	8b 75 08             	mov    0x8(%ebp),%esi
  801e9d:	8a 45 0c             	mov    0xc(%ebp),%al
  801ea0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801ea3:	89 34 24             	mov    %esi,(%esp)
  801ea6:	e8 b9 fe ff ff       	call   801d64 <fd2num>
  801eab:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801eae:	89 54 24 04          	mov    %edx,0x4(%esp)
  801eb2:	89 04 24             	mov    %eax,(%esp)
  801eb5:	e8 28 ff ff ff       	call   801de2 <fd_lookup>
  801eba:	89 c3                	mov    %eax,%ebx
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	78 05                	js     801ec5 <fd_close+0x33>
	    || fd != fd2)
  801ec0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801ec3:	74 0d                	je     801ed2 <fd_close+0x40>
		return (must_exist ? r : 0);
  801ec5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801ec9:	75 46                	jne    801f11 <fd_close+0x7f>
  801ecb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ed0:	eb 3f                	jmp    801f11 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801ed2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ed5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed9:	8b 06                	mov    (%esi),%eax
  801edb:	89 04 24             	mov    %eax,(%esp)
  801ede:	e8 55 ff ff ff       	call   801e38 <dev_lookup>
  801ee3:	89 c3                	mov    %eax,%ebx
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	78 18                	js     801f01 <fd_close+0x6f>
		if (dev->dev_close)
  801ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eec:	8b 40 10             	mov    0x10(%eax),%eax
  801eef:	85 c0                	test   %eax,%eax
  801ef1:	74 09                	je     801efc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801ef3:	89 34 24             	mov    %esi,(%esp)
  801ef6:	ff d0                	call   *%eax
  801ef8:	89 c3                	mov    %eax,%ebx
  801efa:	eb 05                	jmp    801f01 <fd_close+0x6f>
		else
			r = 0;
  801efc:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801f01:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f0c:	e8 2f f7 ff ff       	call   801640 <sys_page_unmap>
	return r;
}
  801f11:	89 d8                	mov    %ebx,%eax
  801f13:	83 c4 30             	add    $0x30,%esp
  801f16:	5b                   	pop    %ebx
  801f17:	5e                   	pop    %esi
  801f18:	5d                   	pop    %ebp
  801f19:	c3                   	ret    

00801f1a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f27:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2a:	89 04 24             	mov    %eax,(%esp)
  801f2d:	e8 b0 fe ff ff       	call   801de2 <fd_lookup>
  801f32:	85 c0                	test   %eax,%eax
  801f34:	78 13                	js     801f49 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801f36:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801f3d:	00 
  801f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f41:	89 04 24             	mov    %eax,(%esp)
  801f44:	e8 49 ff ff ff       	call   801e92 <fd_close>
}
  801f49:	c9                   	leave  
  801f4a:	c3                   	ret    

00801f4b <close_all>:

void
close_all(void)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	53                   	push   %ebx
  801f4f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801f52:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801f57:	89 1c 24             	mov    %ebx,(%esp)
  801f5a:	e8 bb ff ff ff       	call   801f1a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801f5f:	43                   	inc    %ebx
  801f60:	83 fb 20             	cmp    $0x20,%ebx
  801f63:	75 f2                	jne    801f57 <close_all+0xc>
		close(i);
}
  801f65:	83 c4 14             	add    $0x14,%esp
  801f68:	5b                   	pop    %ebx
  801f69:	5d                   	pop    %ebp
  801f6a:	c3                   	ret    

00801f6b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801f6b:	55                   	push   %ebp
  801f6c:	89 e5                	mov    %esp,%ebp
  801f6e:	57                   	push   %edi
  801f6f:	56                   	push   %esi
  801f70:	53                   	push   %ebx
  801f71:	83 ec 4c             	sub    $0x4c,%esp
  801f74:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801f77:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801f7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f81:	89 04 24             	mov    %eax,(%esp)
  801f84:	e8 59 fe ff ff       	call   801de2 <fd_lookup>
  801f89:	89 c3                	mov    %eax,%ebx
  801f8b:	85 c0                	test   %eax,%eax
  801f8d:	0f 88 e1 00 00 00    	js     802074 <dup+0x109>
		return r;
	close(newfdnum);
  801f93:	89 3c 24             	mov    %edi,(%esp)
  801f96:	e8 7f ff ff ff       	call   801f1a <close>

	newfd = INDEX2FD(newfdnum);
  801f9b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801fa1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801fa4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fa7:	89 04 24             	mov    %eax,(%esp)
  801faa:	e8 c5 fd ff ff       	call   801d74 <fd2data>
  801faf:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801fb1:	89 34 24             	mov    %esi,(%esp)
  801fb4:	e8 bb fd ff ff       	call   801d74 <fd2data>
  801fb9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	c1 e8 16             	shr    $0x16,%eax
  801fc1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801fc8:	a8 01                	test   $0x1,%al
  801fca:	74 46                	je     802012 <dup+0xa7>
  801fcc:	89 d8                	mov    %ebx,%eax
  801fce:	c1 e8 0c             	shr    $0xc,%eax
  801fd1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801fd8:	f6 c2 01             	test   $0x1,%dl
  801fdb:	74 35                	je     802012 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801fdd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801fe4:	25 07 0e 00 00       	and    $0xe07,%eax
  801fe9:	89 44 24 10          	mov    %eax,0x10(%esp)
  801fed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ff0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ff4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ffb:	00 
  801ffc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802000:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802007:	e8 e1 f5 ff ff       	call   8015ed <sys_page_map>
  80200c:	89 c3                	mov    %eax,%ebx
  80200e:	85 c0                	test   %eax,%eax
  802010:	78 3b                	js     80204d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802012:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802015:	89 c2                	mov    %eax,%edx
  802017:	c1 ea 0c             	shr    $0xc,%edx
  80201a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802021:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  802027:	89 54 24 10          	mov    %edx,0x10(%esp)
  80202b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80202f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802036:	00 
  802037:	89 44 24 04          	mov    %eax,0x4(%esp)
  80203b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802042:	e8 a6 f5 ff ff       	call   8015ed <sys_page_map>
  802047:	89 c3                	mov    %eax,%ebx
  802049:	85 c0                	test   %eax,%eax
  80204b:	79 25                	jns    802072 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80204d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802051:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802058:	e8 e3 f5 ff ff       	call   801640 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80205d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802060:	89 44 24 04          	mov    %eax,0x4(%esp)
  802064:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80206b:	e8 d0 f5 ff ff       	call   801640 <sys_page_unmap>
	return r;
  802070:	eb 02                	jmp    802074 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  802072:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  802074:	89 d8                	mov    %ebx,%eax
  802076:	83 c4 4c             	add    $0x4c,%esp
  802079:	5b                   	pop    %ebx
  80207a:	5e                   	pop    %esi
  80207b:	5f                   	pop    %edi
  80207c:	5d                   	pop    %ebp
  80207d:	c3                   	ret    

0080207e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80207e:	55                   	push   %ebp
  80207f:	89 e5                	mov    %esp,%ebp
  802081:	53                   	push   %ebx
  802082:	83 ec 24             	sub    $0x24,%esp
  802085:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802088:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80208b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80208f:	89 1c 24             	mov    %ebx,(%esp)
  802092:	e8 4b fd ff ff       	call   801de2 <fd_lookup>
  802097:	85 c0                	test   %eax,%eax
  802099:	78 6d                	js     802108 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80209b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a5:	8b 00                	mov    (%eax),%eax
  8020a7:	89 04 24             	mov    %eax,(%esp)
  8020aa:	e8 89 fd ff ff       	call   801e38 <dev_lookup>
  8020af:	85 c0                	test   %eax,%eax
  8020b1:	78 55                	js     802108 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8020b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020b6:	8b 50 08             	mov    0x8(%eax),%edx
  8020b9:	83 e2 03             	and    $0x3,%edx
  8020bc:	83 fa 01             	cmp    $0x1,%edx
  8020bf:	75 23                	jne    8020e4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8020c1:	a1 24 54 80 00       	mov    0x805424,%eax
  8020c6:	8b 40 48             	mov    0x48(%eax),%eax
  8020c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d1:	c7 04 24 dd 3b 80 00 	movl   $0x803bdd,(%esp)
  8020d8:	e8 1f ea ff ff       	call   800afc <cprintf>
		return -E_INVAL;
  8020dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8020e2:	eb 24                	jmp    802108 <read+0x8a>
	}
	if (!dev->dev_read)
  8020e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020e7:	8b 52 08             	mov    0x8(%edx),%edx
  8020ea:	85 d2                	test   %edx,%edx
  8020ec:	74 15                	je     802103 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8020ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8020f1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020f8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020fc:	89 04 24             	mov    %eax,(%esp)
  8020ff:	ff d2                	call   *%edx
  802101:	eb 05                	jmp    802108 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802103:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  802108:	83 c4 24             	add    $0x24,%esp
  80210b:	5b                   	pop    %ebx
  80210c:	5d                   	pop    %ebp
  80210d:	c3                   	ret    

0080210e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80210e:	55                   	push   %ebp
  80210f:	89 e5                	mov    %esp,%ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 7d 08             	mov    0x8(%ebp),%edi
  80211a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80211d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802122:	eb 23                	jmp    802147 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802124:	89 f0                	mov    %esi,%eax
  802126:	29 d8                	sub    %ebx,%eax
  802128:	89 44 24 08          	mov    %eax,0x8(%esp)
  80212c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80212f:	01 d8                	add    %ebx,%eax
  802131:	89 44 24 04          	mov    %eax,0x4(%esp)
  802135:	89 3c 24             	mov    %edi,(%esp)
  802138:	e8 41 ff ff ff       	call   80207e <read>
		if (m < 0)
  80213d:	85 c0                	test   %eax,%eax
  80213f:	78 10                	js     802151 <readn+0x43>
			return m;
		if (m == 0)
  802141:	85 c0                	test   %eax,%eax
  802143:	74 0a                	je     80214f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802145:	01 c3                	add    %eax,%ebx
  802147:	39 f3                	cmp    %esi,%ebx
  802149:	72 d9                	jb     802124 <readn+0x16>
  80214b:	89 d8                	mov    %ebx,%eax
  80214d:	eb 02                	jmp    802151 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80214f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  802151:	83 c4 1c             	add    $0x1c,%esp
  802154:	5b                   	pop    %ebx
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    

00802159 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802159:	55                   	push   %ebp
  80215a:	89 e5                	mov    %esp,%ebp
  80215c:	53                   	push   %ebx
  80215d:	83 ec 24             	sub    $0x24,%esp
  802160:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802163:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802166:	89 44 24 04          	mov    %eax,0x4(%esp)
  80216a:	89 1c 24             	mov    %ebx,(%esp)
  80216d:	e8 70 fc ff ff       	call   801de2 <fd_lookup>
  802172:	85 c0                	test   %eax,%eax
  802174:	78 68                	js     8021de <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802176:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802179:	89 44 24 04          	mov    %eax,0x4(%esp)
  80217d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802180:	8b 00                	mov    (%eax),%eax
  802182:	89 04 24             	mov    %eax,(%esp)
  802185:	e8 ae fc ff ff       	call   801e38 <dev_lookup>
  80218a:	85 c0                	test   %eax,%eax
  80218c:	78 50                	js     8021de <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80218e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802191:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802195:	75 23                	jne    8021ba <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802197:	a1 24 54 80 00       	mov    0x805424,%eax
  80219c:	8b 40 48             	mov    0x48(%eax),%eax
  80219f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a7:	c7 04 24 f9 3b 80 00 	movl   $0x803bf9,(%esp)
  8021ae:	e8 49 e9 ff ff       	call   800afc <cprintf>
		return -E_INVAL;
  8021b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8021b8:	eb 24                	jmp    8021de <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8021ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021bd:	8b 52 0c             	mov    0xc(%edx),%edx
  8021c0:	85 d2                	test   %edx,%edx
  8021c2:	74 15                	je     8021d9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8021c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8021c7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021d2:	89 04 24             	mov    %eax,(%esp)
  8021d5:	ff d2                	call   *%edx
  8021d7:	eb 05                	jmp    8021de <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8021d9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8021de:	83 c4 24             	add    $0x24,%esp
  8021e1:	5b                   	pop    %ebx
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    

008021e4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
  8021e7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021ea:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8021ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f4:	89 04 24             	mov    %eax,(%esp)
  8021f7:	e8 e6 fb ff ff       	call   801de2 <fd_lookup>
  8021fc:	85 c0                	test   %eax,%eax
  8021fe:	78 0e                	js     80220e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  802200:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802203:	8b 55 0c             	mov    0xc(%ebp),%edx
  802206:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802209:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80220e:	c9                   	leave  
  80220f:	c3                   	ret    

00802210 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802210:	55                   	push   %ebp
  802211:	89 e5                	mov    %esp,%ebp
  802213:	53                   	push   %ebx
  802214:	83 ec 24             	sub    $0x24,%esp
  802217:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80221a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80221d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802221:	89 1c 24             	mov    %ebx,(%esp)
  802224:	e8 b9 fb ff ff       	call   801de2 <fd_lookup>
  802229:	85 c0                	test   %eax,%eax
  80222b:	78 61                	js     80228e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80222d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802230:	89 44 24 04          	mov    %eax,0x4(%esp)
  802234:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802237:	8b 00                	mov    (%eax),%eax
  802239:	89 04 24             	mov    %eax,(%esp)
  80223c:	e8 f7 fb ff ff       	call   801e38 <dev_lookup>
  802241:	85 c0                	test   %eax,%eax
  802243:	78 49                	js     80228e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802245:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802248:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80224c:	75 23                	jne    802271 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80224e:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802253:	8b 40 48             	mov    0x48(%eax),%eax
  802256:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80225a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80225e:	c7 04 24 bc 3b 80 00 	movl   $0x803bbc,(%esp)
  802265:	e8 92 e8 ff ff       	call   800afc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80226a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80226f:	eb 1d                	jmp    80228e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  802271:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802274:	8b 52 18             	mov    0x18(%edx),%edx
  802277:	85 d2                	test   %edx,%edx
  802279:	74 0e                	je     802289 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80227b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80227e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802282:	89 04 24             	mov    %eax,(%esp)
  802285:	ff d2                	call   *%edx
  802287:	eb 05                	jmp    80228e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802289:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80228e:	83 c4 24             	add    $0x24,%esp
  802291:	5b                   	pop    %ebx
  802292:	5d                   	pop    %ebp
  802293:	c3                   	ret    

00802294 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802294:	55                   	push   %ebp
  802295:	89 e5                	mov    %esp,%ebp
  802297:	53                   	push   %ebx
  802298:	83 ec 24             	sub    $0x24,%esp
  80229b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80229e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a8:	89 04 24             	mov    %eax,(%esp)
  8022ab:	e8 32 fb ff ff       	call   801de2 <fd_lookup>
  8022b0:	85 c0                	test   %eax,%eax
  8022b2:	78 52                	js     802306 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8022b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022be:	8b 00                	mov    (%eax),%eax
  8022c0:	89 04 24             	mov    %eax,(%esp)
  8022c3:	e8 70 fb ff ff       	call   801e38 <dev_lookup>
  8022c8:	85 c0                	test   %eax,%eax
  8022ca:	78 3a                	js     802306 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8022cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022cf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8022d3:	74 2c                	je     802301 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8022d5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8022d8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8022df:	00 00 00 
	stat->st_isdir = 0;
  8022e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8022e9:	00 00 00 
	stat->st_dev = dev;
  8022ec:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8022f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8022f9:	89 14 24             	mov    %edx,(%esp)
  8022fc:	ff 50 14             	call   *0x14(%eax)
  8022ff:	eb 05                	jmp    802306 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802301:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802306:	83 c4 24             	add    $0x24,%esp
  802309:	5b                   	pop    %ebx
  80230a:	5d                   	pop    %ebp
  80230b:	c3                   	ret    

0080230c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80230c:	55                   	push   %ebp
  80230d:	89 e5                	mov    %esp,%ebp
  80230f:	56                   	push   %esi
  802310:	53                   	push   %ebx
  802311:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802314:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80231b:	00 
  80231c:	8b 45 08             	mov    0x8(%ebp),%eax
  80231f:	89 04 24             	mov    %eax,(%esp)
  802322:	e8 fe 01 00 00       	call   802525 <open>
  802327:	89 c3                	mov    %eax,%ebx
  802329:	85 c0                	test   %eax,%eax
  80232b:	78 1b                	js     802348 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80232d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802330:	89 44 24 04          	mov    %eax,0x4(%esp)
  802334:	89 1c 24             	mov    %ebx,(%esp)
  802337:	e8 58 ff ff ff       	call   802294 <fstat>
  80233c:	89 c6                	mov    %eax,%esi
	close(fd);
  80233e:	89 1c 24             	mov    %ebx,(%esp)
  802341:	e8 d4 fb ff ff       	call   801f1a <close>
	return r;
  802346:	89 f3                	mov    %esi,%ebx
}
  802348:	89 d8                	mov    %ebx,%eax
  80234a:	83 c4 10             	add    $0x10,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5d                   	pop    %ebp
  802350:	c3                   	ret    
  802351:	00 00                	add    %al,(%eax)
	...

00802354 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802354:	55                   	push   %ebp
  802355:	89 e5                	mov    %esp,%ebp
  802357:	56                   	push   %esi
  802358:	53                   	push   %ebx
  802359:	83 ec 10             	sub    $0x10,%esp
  80235c:	89 c3                	mov    %eax,%ebx
  80235e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  802360:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802367:	75 11                	jne    80237a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802369:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  802370:	e8 cc 0e 00 00       	call   803241 <ipc_find_env>
  802375:	a3 20 54 80 00       	mov    %eax,0x805420
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80237a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802381:	00 
  802382:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802389:	00 
  80238a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80238e:	a1 20 54 80 00       	mov    0x805420,%eax
  802393:	89 04 24             	mov    %eax,(%esp)
  802396:	e8 3c 0e 00 00       	call   8031d7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80239b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8023a2:	00 
  8023a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ae:	e8 bd 0d 00 00       	call   803170 <ipc_recv>
}
  8023b3:	83 c4 10             	add    $0x10,%esp
  8023b6:	5b                   	pop    %ebx
  8023b7:	5e                   	pop    %esi
  8023b8:	5d                   	pop    %ebp
  8023b9:	c3                   	ret    

008023ba <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8023ba:	55                   	push   %ebp
  8023bb:	89 e5                	mov    %esp,%ebp
  8023bd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8023c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8023c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8023c6:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8023cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023ce:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8023d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8023d8:	b8 02 00 00 00       	mov    $0x2,%eax
  8023dd:	e8 72 ff ff ff       	call   802354 <fsipc>
}
  8023e2:	c9                   	leave  
  8023e3:	c3                   	ret    

008023e4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8023e4:	55                   	push   %ebp
  8023e5:	89 e5                	mov    %esp,%ebp
  8023e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8023ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8023f0:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8023f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8023fa:	b8 06 00 00 00       	mov    $0x6,%eax
  8023ff:	e8 50 ff ff ff       	call   802354 <fsipc>
}
  802404:	c9                   	leave  
  802405:	c3                   	ret    

00802406 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802406:	55                   	push   %ebp
  802407:	89 e5                	mov    %esp,%ebp
  802409:	53                   	push   %ebx
  80240a:	83 ec 14             	sub    $0x14,%esp
  80240d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802410:	8b 45 08             	mov    0x8(%ebp),%eax
  802413:	8b 40 0c             	mov    0xc(%eax),%eax
  802416:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80241b:	ba 00 00 00 00       	mov    $0x0,%edx
  802420:	b8 05 00 00 00       	mov    $0x5,%eax
  802425:	e8 2a ff ff ff       	call   802354 <fsipc>
  80242a:	85 c0                	test   %eax,%eax
  80242c:	78 2b                	js     802459 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80242e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802435:	00 
  802436:	89 1c 24             	mov    %ebx,(%esp)
  802439:	e8 69 ed ff ff       	call   8011a7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80243e:	a1 80 60 80 00       	mov    0x806080,%eax
  802443:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802449:	a1 84 60 80 00       	mov    0x806084,%eax
  80244e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802454:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802459:	83 c4 14             	add    $0x14,%esp
  80245c:	5b                   	pop    %ebx
  80245d:	5d                   	pop    %ebp
  80245e:	c3                   	ret    

0080245f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80245f:	55                   	push   %ebp
  802460:	89 e5                	mov    %esp,%ebp
  802462:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  802465:	c7 44 24 08 28 3c 80 	movl   $0x803c28,0x8(%esp)
  80246c:	00 
  80246d:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  802474:	00 
  802475:	c7 04 24 46 3c 80 00 	movl   $0x803c46,(%esp)
  80247c:	e8 83 e5 ff ff       	call   800a04 <_panic>

00802481 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802481:	55                   	push   %ebp
  802482:	89 e5                	mov    %esp,%ebp
  802484:	56                   	push   %esi
  802485:	53                   	push   %ebx
  802486:	83 ec 10             	sub    $0x10,%esp
  802489:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80248c:	8b 45 08             	mov    0x8(%ebp),%eax
  80248f:	8b 40 0c             	mov    0xc(%eax),%eax
  802492:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802497:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80249d:	ba 00 00 00 00       	mov    $0x0,%edx
  8024a2:	b8 03 00 00 00       	mov    $0x3,%eax
  8024a7:	e8 a8 fe ff ff       	call   802354 <fsipc>
  8024ac:	89 c3                	mov    %eax,%ebx
  8024ae:	85 c0                	test   %eax,%eax
  8024b0:	78 6a                	js     80251c <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8024b2:	39 c6                	cmp    %eax,%esi
  8024b4:	73 24                	jae    8024da <devfile_read+0x59>
  8024b6:	c7 44 24 0c 51 3c 80 	movl   $0x803c51,0xc(%esp)
  8024bd:	00 
  8024be:	c7 44 24 08 72 36 80 	movl   $0x803672,0x8(%esp)
  8024c5:	00 
  8024c6:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8024cd:	00 
  8024ce:	c7 04 24 46 3c 80 00 	movl   $0x803c46,(%esp)
  8024d5:	e8 2a e5 ff ff       	call   800a04 <_panic>
	assert(r <= PGSIZE);
  8024da:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8024df:	7e 24                	jle    802505 <devfile_read+0x84>
  8024e1:	c7 44 24 0c 58 3c 80 	movl   $0x803c58,0xc(%esp)
  8024e8:	00 
  8024e9:	c7 44 24 08 72 36 80 	movl   $0x803672,0x8(%esp)
  8024f0:	00 
  8024f1:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8024f8:	00 
  8024f9:	c7 04 24 46 3c 80 00 	movl   $0x803c46,(%esp)
  802500:	e8 ff e4 ff ff       	call   800a04 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802505:	89 44 24 08          	mov    %eax,0x8(%esp)
  802509:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802510:	00 
  802511:	8b 45 0c             	mov    0xc(%ebp),%eax
  802514:	89 04 24             	mov    %eax,(%esp)
  802517:	e8 04 ee ff ff       	call   801320 <memmove>
	return r;
}
  80251c:	89 d8                	mov    %ebx,%eax
  80251e:	83 c4 10             	add    $0x10,%esp
  802521:	5b                   	pop    %ebx
  802522:	5e                   	pop    %esi
  802523:	5d                   	pop    %ebp
  802524:	c3                   	ret    

00802525 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802525:	55                   	push   %ebp
  802526:	89 e5                	mov    %esp,%ebp
  802528:	56                   	push   %esi
  802529:	53                   	push   %ebx
  80252a:	83 ec 20             	sub    $0x20,%esp
  80252d:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802530:	89 34 24             	mov    %esi,(%esp)
  802533:	e8 3c ec ff ff       	call   801174 <strlen>
  802538:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80253d:	7f 60                	jg     80259f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80253f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802542:	89 04 24             	mov    %eax,(%esp)
  802545:	e8 45 f8 ff ff       	call   801d8f <fd_alloc>
  80254a:	89 c3                	mov    %eax,%ebx
  80254c:	85 c0                	test   %eax,%eax
  80254e:	78 54                	js     8025a4 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802550:	89 74 24 04          	mov    %esi,0x4(%esp)
  802554:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80255b:	e8 47 ec ff ff       	call   8011a7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802560:	8b 45 0c             	mov    0xc(%ebp),%eax
  802563:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802568:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80256b:	b8 01 00 00 00       	mov    $0x1,%eax
  802570:	e8 df fd ff ff       	call   802354 <fsipc>
  802575:	89 c3                	mov    %eax,%ebx
  802577:	85 c0                	test   %eax,%eax
  802579:	79 15                	jns    802590 <open+0x6b>
		fd_close(fd, 0);
  80257b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802582:	00 
  802583:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802586:	89 04 24             	mov    %eax,(%esp)
  802589:	e8 04 f9 ff ff       	call   801e92 <fd_close>
		return r;
  80258e:	eb 14                	jmp    8025a4 <open+0x7f>
	}

	return fd2num(fd);
  802590:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802593:	89 04 24             	mov    %eax,(%esp)
  802596:	e8 c9 f7 ff ff       	call   801d64 <fd2num>
  80259b:	89 c3                	mov    %eax,%ebx
  80259d:	eb 05                	jmp    8025a4 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80259f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8025a4:	89 d8                	mov    %ebx,%eax
  8025a6:	83 c4 20             	add    $0x20,%esp
  8025a9:	5b                   	pop    %ebx
  8025aa:	5e                   	pop    %esi
  8025ab:	5d                   	pop    %ebp
  8025ac:	c3                   	ret    

008025ad <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8025ad:	55                   	push   %ebp
  8025ae:	89 e5                	mov    %esp,%ebp
  8025b0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8025b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8025b8:	b8 08 00 00 00       	mov    $0x8,%eax
  8025bd:	e8 92 fd ff ff       	call   802354 <fsipc>
}
  8025c2:	c9                   	leave  
  8025c3:	c3                   	ret    

008025c4 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8025c4:	55                   	push   %ebp
  8025c5:	89 e5                	mov    %esp,%ebp
  8025c7:	53                   	push   %ebx
  8025c8:	83 ec 14             	sub    $0x14,%esp
  8025cb:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8025cd:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8025d1:	7e 32                	jle    802605 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8025d3:	8b 40 04             	mov    0x4(%eax),%eax
  8025d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025da:	8d 43 10             	lea    0x10(%ebx),%eax
  8025dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025e1:	8b 03                	mov    (%ebx),%eax
  8025e3:	89 04 24             	mov    %eax,(%esp)
  8025e6:	e8 6e fb ff ff       	call   802159 <write>
		if (result > 0)
  8025eb:	85 c0                	test   %eax,%eax
  8025ed:	7e 03                	jle    8025f2 <writebuf+0x2e>
			b->result += result;
  8025ef:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8025f2:	39 43 04             	cmp    %eax,0x4(%ebx)
  8025f5:	74 0e                	je     802605 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  8025f7:	89 c2                	mov    %eax,%edx
  8025f9:	85 c0                	test   %eax,%eax
  8025fb:	7e 05                	jle    802602 <writebuf+0x3e>
  8025fd:	ba 00 00 00 00       	mov    $0x0,%edx
  802602:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  802605:	83 c4 14             	add    $0x14,%esp
  802608:	5b                   	pop    %ebx
  802609:	5d                   	pop    %ebp
  80260a:	c3                   	ret    

0080260b <putch>:

static void
putch(int ch, void *thunk)
{
  80260b:	55                   	push   %ebp
  80260c:	89 e5                	mov    %esp,%ebp
  80260e:	53                   	push   %ebx
  80260f:	83 ec 04             	sub    $0x4,%esp
  802612:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802615:	8b 43 04             	mov    0x4(%ebx),%eax
  802618:	8b 55 08             	mov    0x8(%ebp),%edx
  80261b:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80261f:	40                   	inc    %eax
  802620:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  802623:	3d 00 01 00 00       	cmp    $0x100,%eax
  802628:	75 0e                	jne    802638 <putch+0x2d>
		writebuf(b);
  80262a:	89 d8                	mov    %ebx,%eax
  80262c:	e8 93 ff ff ff       	call   8025c4 <writebuf>
		b->idx = 0;
  802631:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  802638:	83 c4 04             	add    $0x4,%esp
  80263b:	5b                   	pop    %ebx
  80263c:	5d                   	pop    %ebp
  80263d:	c3                   	ret    

0080263e <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80263e:	55                   	push   %ebp
  80263f:	89 e5                	mov    %esp,%ebp
  802641:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  802647:	8b 45 08             	mov    0x8(%ebp),%eax
  80264a:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802650:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802657:	00 00 00 
	b.result = 0;
  80265a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802661:	00 00 00 
	b.error = 1;
  802664:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80266b:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80266e:	8b 45 10             	mov    0x10(%ebp),%eax
  802671:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802675:	8b 45 0c             	mov    0xc(%ebp),%eax
  802678:	89 44 24 08          	mov    %eax,0x8(%esp)
  80267c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802682:	89 44 24 04          	mov    %eax,0x4(%esp)
  802686:	c7 04 24 0b 26 80 00 	movl   $0x80260b,(%esp)
  80268d:	e8 cc e5 ff ff       	call   800c5e <vprintfmt>
	if (b.idx > 0)
  802692:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802699:	7e 0b                	jle    8026a6 <vfprintf+0x68>
		writebuf(&b);
  80269b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8026a1:	e8 1e ff ff ff       	call   8025c4 <writebuf>

	return (b.result ? b.result : b.error);
  8026a6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8026ac:	85 c0                	test   %eax,%eax
  8026ae:	75 06                	jne    8026b6 <vfprintf+0x78>
  8026b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8026b6:	c9                   	leave  
  8026b7:	c3                   	ret    

008026b8 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8026b8:	55                   	push   %ebp
  8026b9:	89 e5                	mov    %esp,%ebp
  8026bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8026be:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8026c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8026cf:	89 04 24             	mov    %eax,(%esp)
  8026d2:	e8 67 ff ff ff       	call   80263e <vfprintf>
	va_end(ap);

	return cnt;
}
  8026d7:	c9                   	leave  
  8026d8:	c3                   	ret    

008026d9 <printf>:

int
printf(const char *fmt, ...)
{
  8026d9:	55                   	push   %ebp
  8026da:	89 e5                	mov    %esp,%ebp
  8026dc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8026df:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8026e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8026e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8026f4:	e8 45 ff ff ff       	call   80263e <vfprintf>
	va_end(ap);

	return cnt;
}
  8026f9:	c9                   	leave  
  8026fa:	c3                   	ret    
	...

008026fc <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8026fc:	55                   	push   %ebp
  8026fd:	89 e5                	mov    %esp,%ebp
  8026ff:	57                   	push   %edi
  802700:	56                   	push   %esi
  802701:	53                   	push   %ebx
  802702:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  802708:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80270f:	00 
  802710:	8b 45 08             	mov    0x8(%ebp),%eax
  802713:	89 04 24             	mov    %eax,(%esp)
  802716:	e8 0a fe ff ff       	call   802525 <open>
  80271b:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  802721:	85 c0                	test   %eax,%eax
  802723:	0f 88 05 05 00 00    	js     802c2e <spawn+0x532>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802729:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  802730:	00 
  802731:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80273b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802741:	89 04 24             	mov    %eax,(%esp)
  802744:	e8 c5 f9 ff ff       	call   80210e <readn>
  802749:	3d 00 02 00 00       	cmp    $0x200,%eax
  80274e:	75 0c                	jne    80275c <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  802750:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802757:	45 4c 46 
  80275a:	74 3b                	je     802797 <spawn+0x9b>
		close(fd);
  80275c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802762:	89 04 24             	mov    %eax,(%esp)
  802765:	e8 b0 f7 ff ff       	call   801f1a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80276a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802771:	46 
  802772:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  802778:	89 44 24 04          	mov    %eax,0x4(%esp)
  80277c:	c7 04 24 64 3c 80 00 	movl   $0x803c64,(%esp)
  802783:	e8 74 e3 ff ff       	call   800afc <cprintf>
		return -E_NOT_EXEC;
  802788:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  80278f:	ff ff ff 
  802792:	e9 a3 04 00 00       	jmp    802c3a <spawn+0x53e>
  802797:	ba 07 00 00 00       	mov    $0x7,%edx
  80279c:	89 d0                	mov    %edx,%eax
  80279e:	cd 30                	int    $0x30
  8027a0:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8027a6:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8027ac:	85 c0                	test   %eax,%eax
  8027ae:	0f 88 86 04 00 00    	js     802c3a <spawn+0x53e>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8027b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8027b9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8027c0:	c1 e0 07             	shl    $0x7,%eax
  8027c3:	29 d0                	sub    %edx,%eax
  8027c5:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  8027cb:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8027d1:	b9 11 00 00 00       	mov    $0x11,%ecx
  8027d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8027d8:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8027de:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8027e4:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8027e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8027f1:	eb 0d                	jmp    802800 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8027f3:	89 04 24             	mov    %eax,(%esp)
  8027f6:	e8 79 e9 ff ff       	call   801174 <strlen>
  8027fb:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8027ff:	46                   	inc    %esi
  802800:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802802:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802809:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  80280c:	85 c0                	test   %eax,%eax
  80280e:	75 e3                	jne    8027f3 <spawn+0xf7>
  802810:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  802816:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80281c:	bf 00 10 40 00       	mov    $0x401000,%edi
  802821:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802823:	89 f8                	mov    %edi,%eax
  802825:	83 e0 fc             	and    $0xfffffffc,%eax
  802828:	f7 d2                	not    %edx
  80282a:	8d 14 90             	lea    (%eax,%edx,4),%edx
  80282d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802833:	89 d0                	mov    %edx,%eax
  802835:	83 e8 08             	sub    $0x8,%eax
  802838:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80283d:	0f 86 08 04 00 00    	jbe    802c4b <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802843:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80284a:	00 
  80284b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802852:	00 
  802853:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80285a:	e8 3a ed ff ff       	call   801599 <sys_page_alloc>
  80285f:	85 c0                	test   %eax,%eax
  802861:	0f 88 e9 03 00 00    	js     802c50 <spawn+0x554>
  802867:	bb 00 00 00 00       	mov    $0x0,%ebx
  80286c:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  802872:	8b 75 0c             	mov    0xc(%ebp),%esi
  802875:	eb 2e                	jmp    8028a5 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  802877:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80287d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802883:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  802886:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  802889:	89 44 24 04          	mov    %eax,0x4(%esp)
  80288d:	89 3c 24             	mov    %edi,(%esp)
  802890:	e8 12 e9 ff ff       	call   8011a7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802895:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  802898:	89 04 24             	mov    %eax,(%esp)
  80289b:	e8 d4 e8 ff ff       	call   801174 <strlen>
  8028a0:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8028a4:	43                   	inc    %ebx
  8028a5:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8028ab:	7c ca                	jl     802877 <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8028ad:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8028b3:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8028b9:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8028c0:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8028c6:	74 24                	je     8028ec <spawn+0x1f0>
  8028c8:	c7 44 24 0c c4 3c 80 	movl   $0x803cc4,0xc(%esp)
  8028cf:	00 
  8028d0:	c7 44 24 08 72 36 80 	movl   $0x803672,0x8(%esp)
  8028d7:	00 
  8028d8:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  8028df:	00 
  8028e0:	c7 04 24 7e 3c 80 00 	movl   $0x803c7e,(%esp)
  8028e7:	e8 18 e1 ff ff       	call   800a04 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8028ec:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8028f2:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8028f7:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8028fd:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802900:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802906:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802909:	89 d0                	mov    %edx,%eax
  80290b:	2d 08 30 80 11       	sub    $0x11803008,%eax
  802910:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802916:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80291d:	00 
  80291e:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  802925:	ee 
  802926:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80292c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802930:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802937:	00 
  802938:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80293f:	e8 a9 ec ff ff       	call   8015ed <sys_page_map>
  802944:	89 c3                	mov    %eax,%ebx
  802946:	85 c0                	test   %eax,%eax
  802948:	78 1a                	js     802964 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80294a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802951:	00 
  802952:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802959:	e8 e2 ec ff ff       	call   801640 <sys_page_unmap>
  80295e:	89 c3                	mov    %eax,%ebx
  802960:	85 c0                	test   %eax,%eax
  802962:	79 1f                	jns    802983 <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802964:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80296b:	00 
  80296c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802973:	e8 c8 ec ff ff       	call   801640 <sys_page_unmap>
	return r;
  802978:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  80297e:	e9 b7 02 00 00       	jmp    802c3a <spawn+0x53e>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802983:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  802989:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  80298f:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802995:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  80299c:	00 00 00 
  80299f:	e9 bb 01 00 00       	jmp    802b5f <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  8029a4:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8029aa:	83 38 01             	cmpl   $0x1,(%eax)
  8029ad:	0f 85 9f 01 00 00    	jne    802b52 <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8029b3:	89 c2                	mov    %eax,%edx
  8029b5:	8b 40 18             	mov    0x18(%eax),%eax
  8029b8:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  8029bb:	83 f8 01             	cmp    $0x1,%eax
  8029be:	19 c0                	sbb    %eax,%eax
  8029c0:	83 e0 fe             	and    $0xfffffffe,%eax
  8029c3:	83 c0 07             	add    $0x7,%eax
  8029c6:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8029cc:	8b 52 04             	mov    0x4(%edx),%edx
  8029cf:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  8029d5:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8029db:	8b 40 10             	mov    0x10(%eax),%eax
  8029de:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8029e4:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  8029ea:	8b 52 14             	mov    0x14(%edx),%edx
  8029ed:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  8029f3:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8029f9:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8029fc:	89 f8                	mov    %edi,%eax
  8029fe:	25 ff 0f 00 00       	and    $0xfff,%eax
  802a03:	74 16                	je     802a1b <spawn+0x31f>
		va -= i;
  802a05:	29 c7                	sub    %eax,%edi
		memsz += i;
  802a07:	01 c2                	add    %eax,%edx
  802a09:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  802a0f:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  802a15:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802a1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802a20:	e9 1f 01 00 00       	jmp    802b44 <spawn+0x448>
		if (i >= filesz) {
  802a25:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  802a2b:	77 2b                	ja     802a58 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802a2d:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  802a33:	89 54 24 08          	mov    %edx,0x8(%esp)
  802a37:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802a3b:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802a41:	89 04 24             	mov    %eax,(%esp)
  802a44:	e8 50 eb ff ff       	call   801599 <sys_page_alloc>
  802a49:	85 c0                	test   %eax,%eax
  802a4b:	0f 89 e7 00 00 00    	jns    802b38 <spawn+0x43c>
  802a51:	89 c6                	mov    %eax,%esi
  802a53:	e9 b2 01 00 00       	jmp    802c0a <spawn+0x50e>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802a58:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802a5f:	00 
  802a60:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802a67:	00 
  802a68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a6f:	e8 25 eb ff ff       	call   801599 <sys_page_alloc>
  802a74:	85 c0                	test   %eax,%eax
  802a76:	0f 88 84 01 00 00    	js     802c00 <spawn+0x504>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802a7c:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  802a82:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802a84:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a88:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802a8e:	89 04 24             	mov    %eax,(%esp)
  802a91:	e8 4e f7 ff ff       	call   8021e4 <seek>
  802a96:	85 c0                	test   %eax,%eax
  802a98:	0f 88 66 01 00 00    	js     802c04 <spawn+0x508>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802a9e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802aa4:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802aa6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802aab:	76 05                	jbe    802ab2 <spawn+0x3b6>
  802aad:	b8 00 10 00 00       	mov    $0x1000,%eax
  802ab2:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ab6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802abd:	00 
  802abe:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802ac4:	89 04 24             	mov    %eax,(%esp)
  802ac7:	e8 42 f6 ff ff       	call   80210e <readn>
  802acc:	85 c0                	test   %eax,%eax
  802ace:	0f 88 34 01 00 00    	js     802c08 <spawn+0x50c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802ad4:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  802ada:	89 54 24 10          	mov    %edx,0x10(%esp)
  802ade:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802ae2:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802ae8:	89 44 24 08          	mov    %eax,0x8(%esp)
  802aec:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802af3:	00 
  802af4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802afb:	e8 ed ea ff ff       	call   8015ed <sys_page_map>
  802b00:	85 c0                	test   %eax,%eax
  802b02:	79 20                	jns    802b24 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  802b04:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b08:	c7 44 24 08 8a 3c 80 	movl   $0x803c8a,0x8(%esp)
  802b0f:	00 
  802b10:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  802b17:	00 
  802b18:	c7 04 24 7e 3c 80 00 	movl   $0x803c7e,(%esp)
  802b1f:	e8 e0 de ff ff       	call   800a04 <_panic>
			sys_page_unmap(0, UTEMP);
  802b24:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b2b:	00 
  802b2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b33:	e8 08 eb ff ff       	call   801640 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802b38:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802b3e:	81 c7 00 10 00 00    	add    $0x1000,%edi
  802b44:	89 de                	mov    %ebx,%esi
  802b46:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  802b4c:	0f 87 d3 fe ff ff    	ja     802a25 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802b52:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  802b58:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  802b5f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802b66:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  802b6c:	0f 8c 32 fe ff ff    	jl     8029a4 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802b72:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802b78:	89 04 24             	mov    %eax,(%esp)
  802b7b:	e8 9a f3 ff ff       	call   801f1a <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802b80:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802b87:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802b8a:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802b90:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b94:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802b9a:	89 04 24             	mov    %eax,(%esp)
  802b9d:	e8 44 eb ff ff       	call   8016e6 <sys_env_set_trapframe>
  802ba2:	85 c0                	test   %eax,%eax
  802ba4:	79 20                	jns    802bc6 <spawn+0x4ca>
		panic("sys_env_set_trapframe: %e", r);
  802ba6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802baa:	c7 44 24 08 a7 3c 80 	movl   $0x803ca7,0x8(%esp)
  802bb1:	00 
  802bb2:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  802bb9:	00 
  802bba:	c7 04 24 7e 3c 80 00 	movl   $0x803c7e,(%esp)
  802bc1:	e8 3e de ff ff       	call   800a04 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802bc6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802bcd:	00 
  802bce:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802bd4:	89 04 24             	mov    %eax,(%esp)
  802bd7:	e8 b7 ea ff ff       	call   801693 <sys_env_set_status>
  802bdc:	85 c0                	test   %eax,%eax
  802bde:	79 5a                	jns    802c3a <spawn+0x53e>
		panic("sys_env_set_status: %e", r);
  802be0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802be4:	c7 44 24 08 6c 3b 80 	movl   $0x803b6c,0x8(%esp)
  802beb:	00 
  802bec:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  802bf3:	00 
  802bf4:	c7 04 24 7e 3c 80 00 	movl   $0x803c7e,(%esp)
  802bfb:	e8 04 de ff ff       	call   800a04 <_panic>
  802c00:	89 c6                	mov    %eax,%esi
  802c02:	eb 06                	jmp    802c0a <spawn+0x50e>
  802c04:	89 c6                	mov    %eax,%esi
  802c06:	eb 02                	jmp    802c0a <spawn+0x50e>
  802c08:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  802c0a:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802c10:	89 04 24             	mov    %eax,(%esp)
  802c13:	e8 f1 e8 ff ff       	call   801509 <sys_env_destroy>
	close(fd);
  802c18:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802c1e:	89 04 24             	mov    %eax,(%esp)
  802c21:	e8 f4 f2 ff ff       	call   801f1a <close>
	return r;
  802c26:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  802c2c:	eb 0c                	jmp    802c3a <spawn+0x53e>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802c2e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802c34:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802c3a:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802c40:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  802c46:	5b                   	pop    %ebx
  802c47:	5e                   	pop    %esi
  802c48:	5f                   	pop    %edi
  802c49:	5d                   	pop    %ebp
  802c4a:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802c4b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802c50:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  802c56:	eb e2                	jmp    802c3a <spawn+0x53e>

00802c58 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802c58:	55                   	push   %ebp
  802c59:	89 e5                	mov    %esp,%ebp
  802c5b:	57                   	push   %edi
  802c5c:	56                   	push   %esi
  802c5d:	53                   	push   %ebx
  802c5e:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  802c61:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802c64:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802c69:	eb 03                	jmp    802c6e <spawnl+0x16>
		argc++;
  802c6b:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802c6c:	89 d0                	mov    %edx,%eax
  802c6e:	8d 50 04             	lea    0x4(%eax),%edx
  802c71:	83 38 00             	cmpl   $0x0,(%eax)
  802c74:	75 f5                	jne    802c6b <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802c76:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802c7d:	83 e0 f0             	and    $0xfffffff0,%eax
  802c80:	29 c4                	sub    %eax,%esp
  802c82:	8d 7c 24 17          	lea    0x17(%esp),%edi
  802c86:	83 e7 f0             	and    $0xfffffff0,%edi
  802c89:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  802c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c8e:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  802c90:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  802c97:	00 

	va_start(vl, arg0);
  802c98:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802c9b:	b8 00 00 00 00       	mov    $0x0,%eax
  802ca0:	eb 09                	jmp    802cab <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  802ca2:	40                   	inc    %eax
  802ca3:	8b 1a                	mov    (%edx),%ebx
  802ca5:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  802ca8:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802cab:	39 c8                	cmp    %ecx,%eax
  802cad:	75 f3                	jne    802ca2 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802caf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  802cb6:	89 04 24             	mov    %eax,(%esp)
  802cb9:	e8 3e fa ff ff       	call   8026fc <spawn>
}
  802cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cc1:	5b                   	pop    %ebx
  802cc2:	5e                   	pop    %esi
  802cc3:	5f                   	pop    %edi
  802cc4:	5d                   	pop    %ebp
  802cc5:	c3                   	ret    
	...

00802cc8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802cc8:	55                   	push   %ebp
  802cc9:	89 e5                	mov    %esp,%ebp
  802ccb:	56                   	push   %esi
  802ccc:	53                   	push   %ebx
  802ccd:	83 ec 10             	sub    $0x10,%esp
  802cd0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  802cd6:	89 04 24             	mov    %eax,(%esp)
  802cd9:	e8 96 f0 ff ff       	call   801d74 <fd2data>
  802cde:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802ce0:	c7 44 24 04 ea 3c 80 	movl   $0x803cea,0x4(%esp)
  802ce7:	00 
  802ce8:	89 34 24             	mov    %esi,(%esp)
  802ceb:	e8 b7 e4 ff ff       	call   8011a7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802cf0:	8b 43 04             	mov    0x4(%ebx),%eax
  802cf3:	2b 03                	sub    (%ebx),%eax
  802cf5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802cfb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802d02:	00 00 00 
	stat->st_dev = &devpipe;
  802d05:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  802d0c:	40 80 00 
	return 0;
}
  802d0f:	b8 00 00 00 00       	mov    $0x0,%eax
  802d14:	83 c4 10             	add    $0x10,%esp
  802d17:	5b                   	pop    %ebx
  802d18:	5e                   	pop    %esi
  802d19:	5d                   	pop    %ebp
  802d1a:	c3                   	ret    

00802d1b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802d1b:	55                   	push   %ebp
  802d1c:	89 e5                	mov    %esp,%ebp
  802d1e:	53                   	push   %ebx
  802d1f:	83 ec 14             	sub    $0x14,%esp
  802d22:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802d25:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802d29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d30:	e8 0b e9 ff ff       	call   801640 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802d35:	89 1c 24             	mov    %ebx,(%esp)
  802d38:	e8 37 f0 ff ff       	call   801d74 <fd2data>
  802d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d48:	e8 f3 e8 ff ff       	call   801640 <sys_page_unmap>
}
  802d4d:	83 c4 14             	add    $0x14,%esp
  802d50:	5b                   	pop    %ebx
  802d51:	5d                   	pop    %ebp
  802d52:	c3                   	ret    

00802d53 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802d53:	55                   	push   %ebp
  802d54:	89 e5                	mov    %esp,%ebp
  802d56:	57                   	push   %edi
  802d57:	56                   	push   %esi
  802d58:	53                   	push   %ebx
  802d59:	83 ec 2c             	sub    $0x2c,%esp
  802d5c:	89 c7                	mov    %eax,%edi
  802d5e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802d61:	a1 24 54 80 00       	mov    0x805424,%eax
  802d66:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802d69:	89 3c 24             	mov    %edi,(%esp)
  802d6c:	e8 17 05 00 00       	call   803288 <pageref>
  802d71:	89 c6                	mov    %eax,%esi
  802d73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802d76:	89 04 24             	mov    %eax,(%esp)
  802d79:	e8 0a 05 00 00       	call   803288 <pageref>
  802d7e:	39 c6                	cmp    %eax,%esi
  802d80:	0f 94 c0             	sete   %al
  802d83:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802d86:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802d8c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802d8f:	39 cb                	cmp    %ecx,%ebx
  802d91:	75 08                	jne    802d9b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802d93:	83 c4 2c             	add    $0x2c,%esp
  802d96:	5b                   	pop    %ebx
  802d97:	5e                   	pop    %esi
  802d98:	5f                   	pop    %edi
  802d99:	5d                   	pop    %ebp
  802d9a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802d9b:	83 f8 01             	cmp    $0x1,%eax
  802d9e:	75 c1                	jne    802d61 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802da0:	8b 42 58             	mov    0x58(%edx),%eax
  802da3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802daa:	00 
  802dab:	89 44 24 08          	mov    %eax,0x8(%esp)
  802daf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802db3:	c7 04 24 f1 3c 80 00 	movl   $0x803cf1,(%esp)
  802dba:	e8 3d dd ff ff       	call   800afc <cprintf>
  802dbf:	eb a0                	jmp    802d61 <_pipeisclosed+0xe>

00802dc1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802dc1:	55                   	push   %ebp
  802dc2:	89 e5                	mov    %esp,%ebp
  802dc4:	57                   	push   %edi
  802dc5:	56                   	push   %esi
  802dc6:	53                   	push   %ebx
  802dc7:	83 ec 1c             	sub    $0x1c,%esp
  802dca:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802dcd:	89 34 24             	mov    %esi,(%esp)
  802dd0:	e8 9f ef ff ff       	call   801d74 <fd2data>
  802dd5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802dd7:	bf 00 00 00 00       	mov    $0x0,%edi
  802ddc:	eb 3c                	jmp    802e1a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802dde:	89 da                	mov    %ebx,%edx
  802de0:	89 f0                	mov    %esi,%eax
  802de2:	e8 6c ff ff ff       	call   802d53 <_pipeisclosed>
  802de7:	85 c0                	test   %eax,%eax
  802de9:	75 38                	jne    802e23 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802deb:	e8 8a e7 ff ff       	call   80157a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802df0:	8b 43 04             	mov    0x4(%ebx),%eax
  802df3:	8b 13                	mov    (%ebx),%edx
  802df5:	83 c2 20             	add    $0x20,%edx
  802df8:	39 d0                	cmp    %edx,%eax
  802dfa:	73 e2                	jae    802dde <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802dfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  802dff:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802e02:	89 c2                	mov    %eax,%edx
  802e04:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802e0a:	79 05                	jns    802e11 <devpipe_write+0x50>
  802e0c:	4a                   	dec    %edx
  802e0d:	83 ca e0             	or     $0xffffffe0,%edx
  802e10:	42                   	inc    %edx
  802e11:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802e15:	40                   	inc    %eax
  802e16:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802e19:	47                   	inc    %edi
  802e1a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802e1d:	75 d1                	jne    802df0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802e1f:	89 f8                	mov    %edi,%eax
  802e21:	eb 05                	jmp    802e28 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802e23:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802e28:	83 c4 1c             	add    $0x1c,%esp
  802e2b:	5b                   	pop    %ebx
  802e2c:	5e                   	pop    %esi
  802e2d:	5f                   	pop    %edi
  802e2e:	5d                   	pop    %ebp
  802e2f:	c3                   	ret    

00802e30 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802e30:	55                   	push   %ebp
  802e31:	89 e5                	mov    %esp,%ebp
  802e33:	57                   	push   %edi
  802e34:	56                   	push   %esi
  802e35:	53                   	push   %ebx
  802e36:	83 ec 1c             	sub    $0x1c,%esp
  802e39:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802e3c:	89 3c 24             	mov    %edi,(%esp)
  802e3f:	e8 30 ef ff ff       	call   801d74 <fd2data>
  802e44:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802e46:	be 00 00 00 00       	mov    $0x0,%esi
  802e4b:	eb 3a                	jmp    802e87 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802e4d:	85 f6                	test   %esi,%esi
  802e4f:	74 04                	je     802e55 <devpipe_read+0x25>
				return i;
  802e51:	89 f0                	mov    %esi,%eax
  802e53:	eb 40                	jmp    802e95 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802e55:	89 da                	mov    %ebx,%edx
  802e57:	89 f8                	mov    %edi,%eax
  802e59:	e8 f5 fe ff ff       	call   802d53 <_pipeisclosed>
  802e5e:	85 c0                	test   %eax,%eax
  802e60:	75 2e                	jne    802e90 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802e62:	e8 13 e7 ff ff       	call   80157a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802e67:	8b 03                	mov    (%ebx),%eax
  802e69:	3b 43 04             	cmp    0x4(%ebx),%eax
  802e6c:	74 df                	je     802e4d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802e6e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802e73:	79 05                	jns    802e7a <devpipe_read+0x4a>
  802e75:	48                   	dec    %eax
  802e76:	83 c8 e0             	or     $0xffffffe0,%eax
  802e79:	40                   	inc    %eax
  802e7a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802e7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802e81:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802e84:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802e86:	46                   	inc    %esi
  802e87:	3b 75 10             	cmp    0x10(%ebp),%esi
  802e8a:	75 db                	jne    802e67 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802e8c:	89 f0                	mov    %esi,%eax
  802e8e:	eb 05                	jmp    802e95 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802e90:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802e95:	83 c4 1c             	add    $0x1c,%esp
  802e98:	5b                   	pop    %ebx
  802e99:	5e                   	pop    %esi
  802e9a:	5f                   	pop    %edi
  802e9b:	5d                   	pop    %ebp
  802e9c:	c3                   	ret    

00802e9d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802e9d:	55                   	push   %ebp
  802e9e:	89 e5                	mov    %esp,%ebp
  802ea0:	57                   	push   %edi
  802ea1:	56                   	push   %esi
  802ea2:	53                   	push   %ebx
  802ea3:	83 ec 3c             	sub    $0x3c,%esp
  802ea6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802ea9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802eac:	89 04 24             	mov    %eax,(%esp)
  802eaf:	e8 db ee ff ff       	call   801d8f <fd_alloc>
  802eb4:	89 c3                	mov    %eax,%ebx
  802eb6:	85 c0                	test   %eax,%eax
  802eb8:	0f 88 45 01 00 00    	js     803003 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ebe:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802ec5:	00 
  802ec6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ecd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ed4:	e8 c0 e6 ff ff       	call   801599 <sys_page_alloc>
  802ed9:	89 c3                	mov    %eax,%ebx
  802edb:	85 c0                	test   %eax,%eax
  802edd:	0f 88 20 01 00 00    	js     803003 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802ee3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802ee6:	89 04 24             	mov    %eax,(%esp)
  802ee9:	e8 a1 ee ff ff       	call   801d8f <fd_alloc>
  802eee:	89 c3                	mov    %eax,%ebx
  802ef0:	85 c0                	test   %eax,%eax
  802ef2:	0f 88 f8 00 00 00    	js     802ff0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ef8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802eff:	00 
  802f00:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802f03:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f0e:	e8 86 e6 ff ff       	call   801599 <sys_page_alloc>
  802f13:	89 c3                	mov    %eax,%ebx
  802f15:	85 c0                	test   %eax,%eax
  802f17:	0f 88 d3 00 00 00    	js     802ff0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802f1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802f20:	89 04 24             	mov    %eax,(%esp)
  802f23:	e8 4c ee ff ff       	call   801d74 <fd2data>
  802f28:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802f2a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802f31:	00 
  802f32:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f3d:	e8 57 e6 ff ff       	call   801599 <sys_page_alloc>
  802f42:	89 c3                	mov    %eax,%ebx
  802f44:	85 c0                	test   %eax,%eax
  802f46:	0f 88 91 00 00 00    	js     802fdd <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802f4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802f4f:	89 04 24             	mov    %eax,(%esp)
  802f52:	e8 1d ee ff ff       	call   801d74 <fd2data>
  802f57:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802f5e:	00 
  802f5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802f63:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802f6a:	00 
  802f6b:	89 74 24 04          	mov    %esi,0x4(%esp)
  802f6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f76:	e8 72 e6 ff ff       	call   8015ed <sys_page_map>
  802f7b:	89 c3                	mov    %eax,%ebx
  802f7d:	85 c0                	test   %eax,%eax
  802f7f:	78 4c                	js     802fcd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802f81:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802f87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802f8a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802f8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802f8f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802f96:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802f9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802f9f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802fa1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802fa4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802fab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802fae:	89 04 24             	mov    %eax,(%esp)
  802fb1:	e8 ae ed ff ff       	call   801d64 <fd2num>
  802fb6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802fb8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802fbb:	89 04 24             	mov    %eax,(%esp)
  802fbe:	e8 a1 ed ff ff       	call   801d64 <fd2num>
  802fc3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  802fcb:	eb 36                	jmp    803003 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802fcd:	89 74 24 04          	mov    %esi,0x4(%esp)
  802fd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802fd8:	e8 63 e6 ff ff       	call   801640 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802fdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802fe0:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fe4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802feb:	e8 50 e6 ff ff       	call   801640 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802ff0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ff3:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ff7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ffe:	e8 3d e6 ff ff       	call   801640 <sys_page_unmap>
    err:
	return r;
}
  803003:	89 d8                	mov    %ebx,%eax
  803005:	83 c4 3c             	add    $0x3c,%esp
  803008:	5b                   	pop    %ebx
  803009:	5e                   	pop    %esi
  80300a:	5f                   	pop    %edi
  80300b:	5d                   	pop    %ebp
  80300c:	c3                   	ret    

0080300d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80300d:	55                   	push   %ebp
  80300e:	89 e5                	mov    %esp,%ebp
  803010:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803013:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803016:	89 44 24 04          	mov    %eax,0x4(%esp)
  80301a:	8b 45 08             	mov    0x8(%ebp),%eax
  80301d:	89 04 24             	mov    %eax,(%esp)
  803020:	e8 bd ed ff ff       	call   801de2 <fd_lookup>
  803025:	85 c0                	test   %eax,%eax
  803027:	78 15                	js     80303e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803029:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80302c:	89 04 24             	mov    %eax,(%esp)
  80302f:	e8 40 ed ff ff       	call   801d74 <fd2data>
	return _pipeisclosed(fd, p);
  803034:	89 c2                	mov    %eax,%edx
  803036:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803039:	e8 15 fd ff ff       	call   802d53 <_pipeisclosed>
}
  80303e:	c9                   	leave  
  80303f:	c3                   	ret    

00803040 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  803040:	55                   	push   %ebp
  803041:	89 e5                	mov    %esp,%ebp
  803043:	56                   	push   %esi
  803044:	53                   	push   %ebx
  803045:	83 ec 10             	sub    $0x10,%esp
  803048:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80304b:	85 f6                	test   %esi,%esi
  80304d:	75 24                	jne    803073 <wait+0x33>
  80304f:	c7 44 24 0c 09 3d 80 	movl   $0x803d09,0xc(%esp)
  803056:	00 
  803057:	c7 44 24 08 72 36 80 	movl   $0x803672,0x8(%esp)
  80305e:	00 
  80305f:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  803066:	00 
  803067:	c7 04 24 14 3d 80 00 	movl   $0x803d14,(%esp)
  80306e:	e8 91 d9 ff ff       	call   800a04 <_panic>
	e = &envs[ENVX(envid)];
  803073:	89 f3                	mov    %esi,%ebx
  803075:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80307b:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  803082:	c1 e3 07             	shl    $0x7,%ebx
  803085:	29 c3                	sub    %eax,%ebx
  803087:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80308d:	eb 05                	jmp    803094 <wait+0x54>
		sys_yield();
  80308f:	e8 e6 e4 ff ff       	call   80157a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803094:	8b 43 48             	mov    0x48(%ebx),%eax
  803097:	39 f0                	cmp    %esi,%eax
  803099:	75 07                	jne    8030a2 <wait+0x62>
  80309b:	8b 43 54             	mov    0x54(%ebx),%eax
  80309e:	85 c0                	test   %eax,%eax
  8030a0:	75 ed                	jne    80308f <wait+0x4f>
		sys_yield();
}
  8030a2:	83 c4 10             	add    $0x10,%esp
  8030a5:	5b                   	pop    %ebx
  8030a6:	5e                   	pop    %esi
  8030a7:	5d                   	pop    %ebp
  8030a8:	c3                   	ret    
  8030a9:	00 00                	add    %al,(%eax)
	...

008030ac <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8030ac:	55                   	push   %ebp
  8030ad:	89 e5                	mov    %esp,%ebp
  8030af:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8030b2:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8030b9:	0f 85 80 00 00 00    	jne    80313f <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  8030bf:	a1 24 54 80 00       	mov    0x805424,%eax
  8030c4:	8b 40 48             	mov    0x48(%eax),%eax
  8030c7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8030ce:	00 
  8030cf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8030d6:	ee 
  8030d7:	89 04 24             	mov    %eax,(%esp)
  8030da:	e8 ba e4 ff ff       	call   801599 <sys_page_alloc>
  8030df:	85 c0                	test   %eax,%eax
  8030e1:	79 20                	jns    803103 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  8030e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8030e7:	c7 44 24 08 20 3d 80 	movl   $0x803d20,0x8(%esp)
  8030ee:	00 
  8030ef:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8030f6:	00 
  8030f7:	c7 04 24 7c 3d 80 00 	movl   $0x803d7c,(%esp)
  8030fe:	e8 01 d9 ff ff       	call   800a04 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  803103:	a1 24 54 80 00       	mov    0x805424,%eax
  803108:	8b 40 48             	mov    0x48(%eax),%eax
  80310b:	c7 44 24 04 4c 31 80 	movl   $0x80314c,0x4(%esp)
  803112:	00 
  803113:	89 04 24             	mov    %eax,(%esp)
  803116:	e8 1e e6 ff ff       	call   801739 <sys_env_set_pgfault_upcall>
  80311b:	85 c0                	test   %eax,%eax
  80311d:	79 20                	jns    80313f <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  80311f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803123:	c7 44 24 08 4c 3d 80 	movl   $0x803d4c,0x8(%esp)
  80312a:	00 
  80312b:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  803132:	00 
  803133:	c7 04 24 7c 3d 80 00 	movl   $0x803d7c,(%esp)
  80313a:	e8 c5 d8 ff ff       	call   800a04 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80313f:	8b 45 08             	mov    0x8(%ebp),%eax
  803142:	a3 00 70 80 00       	mov    %eax,0x807000
}
  803147:	c9                   	leave  
  803148:	c3                   	ret    
  803149:	00 00                	add    %al,(%eax)
	...

0080314c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80314c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80314d:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  803152:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  803154:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  803157:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  80315b:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  80315d:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  803160:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  803161:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  803164:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  803166:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  803169:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  80316a:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  80316d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80316e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80316f:	c3                   	ret    

00803170 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  803170:	55                   	push   %ebp
  803171:	89 e5                	mov    %esp,%ebp
  803173:	56                   	push   %esi
  803174:	53                   	push   %ebx
  803175:	83 ec 10             	sub    $0x10,%esp
  803178:	8b 75 08             	mov    0x8(%ebp),%esi
  80317b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80317e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  803181:	85 c0                	test   %eax,%eax
  803183:	75 05                	jne    80318a <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  803185:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  80318a:	89 04 24             	mov    %eax,(%esp)
  80318d:	e8 1d e6 ff ff       	call   8017af <sys_ipc_recv>
	if (!err) {
  803192:	85 c0                	test   %eax,%eax
  803194:	75 26                	jne    8031bc <ipc_recv+0x4c>
		if (from_env_store) {
  803196:	85 f6                	test   %esi,%esi
  803198:	74 0a                	je     8031a4 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  80319a:	a1 24 54 80 00       	mov    0x805424,%eax
  80319f:	8b 40 74             	mov    0x74(%eax),%eax
  8031a2:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8031a4:	85 db                	test   %ebx,%ebx
  8031a6:	74 0a                	je     8031b2 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  8031a8:	a1 24 54 80 00       	mov    0x805424,%eax
  8031ad:	8b 40 78             	mov    0x78(%eax),%eax
  8031b0:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  8031b2:	a1 24 54 80 00       	mov    0x805424,%eax
  8031b7:	8b 40 70             	mov    0x70(%eax),%eax
  8031ba:	eb 14                	jmp    8031d0 <ipc_recv+0x60>
	}
	if (from_env_store) {
  8031bc:	85 f6                	test   %esi,%esi
  8031be:	74 06                	je     8031c6 <ipc_recv+0x56>
		*from_env_store = 0;
  8031c0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  8031c6:	85 db                	test   %ebx,%ebx
  8031c8:	74 06                	je     8031d0 <ipc_recv+0x60>
		*perm_store = 0;
  8031ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  8031d0:	83 c4 10             	add    $0x10,%esp
  8031d3:	5b                   	pop    %ebx
  8031d4:	5e                   	pop    %esi
  8031d5:	5d                   	pop    %ebp
  8031d6:	c3                   	ret    

008031d7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8031d7:	55                   	push   %ebp
  8031d8:	89 e5                	mov    %esp,%ebp
  8031da:	57                   	push   %edi
  8031db:	56                   	push   %esi
  8031dc:	53                   	push   %ebx
  8031dd:	83 ec 1c             	sub    $0x1c,%esp
  8031e0:	8b 75 10             	mov    0x10(%ebp),%esi
  8031e3:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  8031e6:	85 f6                	test   %esi,%esi
  8031e8:	75 05                	jne    8031ef <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  8031ea:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  8031ef:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8031f3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8031f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031fe:	8b 45 08             	mov    0x8(%ebp),%eax
  803201:	89 04 24             	mov    %eax,(%esp)
  803204:	e8 83 e5 ff ff       	call   80178c <sys_ipc_try_send>
  803209:	89 c3                	mov    %eax,%ebx
		sys_yield();
  80320b:	e8 6a e3 ff ff       	call   80157a <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  803210:	83 fb f9             	cmp    $0xfffffff9,%ebx
  803213:	74 da                	je     8031ef <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  803215:	85 db                	test   %ebx,%ebx
  803217:	74 20                	je     803239 <ipc_send+0x62>
		panic("send fail: %e", err);
  803219:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80321d:	c7 44 24 08 8a 3d 80 	movl   $0x803d8a,0x8(%esp)
  803224:	00 
  803225:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  80322c:	00 
  80322d:	c7 04 24 98 3d 80 00 	movl   $0x803d98,(%esp)
  803234:	e8 cb d7 ff ff       	call   800a04 <_panic>
	}
	return;
}
  803239:	83 c4 1c             	add    $0x1c,%esp
  80323c:	5b                   	pop    %ebx
  80323d:	5e                   	pop    %esi
  80323e:	5f                   	pop    %edi
  80323f:	5d                   	pop    %ebp
  803240:	c3                   	ret    

00803241 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803241:	55                   	push   %ebp
  803242:	89 e5                	mov    %esp,%ebp
  803244:	53                   	push   %ebx
  803245:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  803248:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80324d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  803254:	89 c2                	mov    %eax,%edx
  803256:	c1 e2 07             	shl    $0x7,%edx
  803259:	29 ca                	sub    %ecx,%edx
  80325b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803261:	8b 52 50             	mov    0x50(%edx),%edx
  803264:	39 da                	cmp    %ebx,%edx
  803266:	75 0f                	jne    803277 <ipc_find_env+0x36>
			return envs[i].env_id;
  803268:	c1 e0 07             	shl    $0x7,%eax
  80326b:	29 c8                	sub    %ecx,%eax
  80326d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  803272:	8b 40 40             	mov    0x40(%eax),%eax
  803275:	eb 0c                	jmp    803283 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803277:	40                   	inc    %eax
  803278:	3d 00 04 00 00       	cmp    $0x400,%eax
  80327d:	75 ce                	jne    80324d <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80327f:	66 b8 00 00          	mov    $0x0,%ax
}
  803283:	5b                   	pop    %ebx
  803284:	5d                   	pop    %ebp
  803285:	c3                   	ret    
	...

00803288 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803288:	55                   	push   %ebp
  803289:	89 e5                	mov    %esp,%ebp
  80328b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80328e:	89 c2                	mov    %eax,%edx
  803290:	c1 ea 16             	shr    $0x16,%edx
  803293:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80329a:	f6 c2 01             	test   $0x1,%dl
  80329d:	74 1e                	je     8032bd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80329f:	c1 e8 0c             	shr    $0xc,%eax
  8032a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8032a9:	a8 01                	test   $0x1,%al
  8032ab:	74 17                	je     8032c4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8032ad:	c1 e8 0c             	shr    $0xc,%eax
  8032b0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8032b7:	ef 
  8032b8:	0f b7 c0             	movzwl %ax,%eax
  8032bb:	eb 0c                	jmp    8032c9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8032bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8032c2:	eb 05                	jmp    8032c9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8032c4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8032c9:	5d                   	pop    %ebp
  8032ca:	c3                   	ret    
	...

008032cc <__udivdi3>:
  8032cc:	55                   	push   %ebp
  8032cd:	57                   	push   %edi
  8032ce:	56                   	push   %esi
  8032cf:	83 ec 10             	sub    $0x10,%esp
  8032d2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8032d6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8032da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8032de:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8032e2:	89 cd                	mov    %ecx,%ebp
  8032e4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8032e8:	85 c0                	test   %eax,%eax
  8032ea:	75 2c                	jne    803318 <__udivdi3+0x4c>
  8032ec:	39 f9                	cmp    %edi,%ecx
  8032ee:	77 68                	ja     803358 <__udivdi3+0x8c>
  8032f0:	85 c9                	test   %ecx,%ecx
  8032f2:	75 0b                	jne    8032ff <__udivdi3+0x33>
  8032f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8032f9:	31 d2                	xor    %edx,%edx
  8032fb:	f7 f1                	div    %ecx
  8032fd:	89 c1                	mov    %eax,%ecx
  8032ff:	31 d2                	xor    %edx,%edx
  803301:	89 f8                	mov    %edi,%eax
  803303:	f7 f1                	div    %ecx
  803305:	89 c7                	mov    %eax,%edi
  803307:	89 f0                	mov    %esi,%eax
  803309:	f7 f1                	div    %ecx
  80330b:	89 c6                	mov    %eax,%esi
  80330d:	89 f0                	mov    %esi,%eax
  80330f:	89 fa                	mov    %edi,%edx
  803311:	83 c4 10             	add    $0x10,%esp
  803314:	5e                   	pop    %esi
  803315:	5f                   	pop    %edi
  803316:	5d                   	pop    %ebp
  803317:	c3                   	ret    
  803318:	39 f8                	cmp    %edi,%eax
  80331a:	77 2c                	ja     803348 <__udivdi3+0x7c>
  80331c:	0f bd f0             	bsr    %eax,%esi
  80331f:	83 f6 1f             	xor    $0x1f,%esi
  803322:	75 4c                	jne    803370 <__udivdi3+0xa4>
  803324:	39 f8                	cmp    %edi,%eax
  803326:	bf 00 00 00 00       	mov    $0x0,%edi
  80332b:	72 0a                	jb     803337 <__udivdi3+0x6b>
  80332d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  803331:	0f 87 ad 00 00 00    	ja     8033e4 <__udivdi3+0x118>
  803337:	be 01 00 00 00       	mov    $0x1,%esi
  80333c:	89 f0                	mov    %esi,%eax
  80333e:	89 fa                	mov    %edi,%edx
  803340:	83 c4 10             	add    $0x10,%esp
  803343:	5e                   	pop    %esi
  803344:	5f                   	pop    %edi
  803345:	5d                   	pop    %ebp
  803346:	c3                   	ret    
  803347:	90                   	nop
  803348:	31 ff                	xor    %edi,%edi
  80334a:	31 f6                	xor    %esi,%esi
  80334c:	89 f0                	mov    %esi,%eax
  80334e:	89 fa                	mov    %edi,%edx
  803350:	83 c4 10             	add    $0x10,%esp
  803353:	5e                   	pop    %esi
  803354:	5f                   	pop    %edi
  803355:	5d                   	pop    %ebp
  803356:	c3                   	ret    
  803357:	90                   	nop
  803358:	89 fa                	mov    %edi,%edx
  80335a:	89 f0                	mov    %esi,%eax
  80335c:	f7 f1                	div    %ecx
  80335e:	89 c6                	mov    %eax,%esi
  803360:	31 ff                	xor    %edi,%edi
  803362:	89 f0                	mov    %esi,%eax
  803364:	89 fa                	mov    %edi,%edx
  803366:	83 c4 10             	add    $0x10,%esp
  803369:	5e                   	pop    %esi
  80336a:	5f                   	pop    %edi
  80336b:	5d                   	pop    %ebp
  80336c:	c3                   	ret    
  80336d:	8d 76 00             	lea    0x0(%esi),%esi
  803370:	89 f1                	mov    %esi,%ecx
  803372:	d3 e0                	shl    %cl,%eax
  803374:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803378:	b8 20 00 00 00       	mov    $0x20,%eax
  80337d:	29 f0                	sub    %esi,%eax
  80337f:	89 ea                	mov    %ebp,%edx
  803381:	88 c1                	mov    %al,%cl
  803383:	d3 ea                	shr    %cl,%edx
  803385:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  803389:	09 ca                	or     %ecx,%edx
  80338b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80338f:	89 f1                	mov    %esi,%ecx
  803391:	d3 e5                	shl    %cl,%ebp
  803393:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  803397:	89 fd                	mov    %edi,%ebp
  803399:	88 c1                	mov    %al,%cl
  80339b:	d3 ed                	shr    %cl,%ebp
  80339d:	89 fa                	mov    %edi,%edx
  80339f:	89 f1                	mov    %esi,%ecx
  8033a1:	d3 e2                	shl    %cl,%edx
  8033a3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8033a7:	88 c1                	mov    %al,%cl
  8033a9:	d3 ef                	shr    %cl,%edi
  8033ab:	09 d7                	or     %edx,%edi
  8033ad:	89 f8                	mov    %edi,%eax
  8033af:	89 ea                	mov    %ebp,%edx
  8033b1:	f7 74 24 08          	divl   0x8(%esp)
  8033b5:	89 d1                	mov    %edx,%ecx
  8033b7:	89 c7                	mov    %eax,%edi
  8033b9:	f7 64 24 0c          	mull   0xc(%esp)
  8033bd:	39 d1                	cmp    %edx,%ecx
  8033bf:	72 17                	jb     8033d8 <__udivdi3+0x10c>
  8033c1:	74 09                	je     8033cc <__udivdi3+0x100>
  8033c3:	89 fe                	mov    %edi,%esi
  8033c5:	31 ff                	xor    %edi,%edi
  8033c7:	e9 41 ff ff ff       	jmp    80330d <__udivdi3+0x41>
  8033cc:	8b 54 24 04          	mov    0x4(%esp),%edx
  8033d0:	89 f1                	mov    %esi,%ecx
  8033d2:	d3 e2                	shl    %cl,%edx
  8033d4:	39 c2                	cmp    %eax,%edx
  8033d6:	73 eb                	jae    8033c3 <__udivdi3+0xf7>
  8033d8:	8d 77 ff             	lea    -0x1(%edi),%esi
  8033db:	31 ff                	xor    %edi,%edi
  8033dd:	e9 2b ff ff ff       	jmp    80330d <__udivdi3+0x41>
  8033e2:	66 90                	xchg   %ax,%ax
  8033e4:	31 f6                	xor    %esi,%esi
  8033e6:	e9 22 ff ff ff       	jmp    80330d <__udivdi3+0x41>
	...

008033ec <__umoddi3>:
  8033ec:	55                   	push   %ebp
  8033ed:	57                   	push   %edi
  8033ee:	56                   	push   %esi
  8033ef:	83 ec 20             	sub    $0x20,%esp
  8033f2:	8b 44 24 30          	mov    0x30(%esp),%eax
  8033f6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8033fa:	89 44 24 14          	mov    %eax,0x14(%esp)
  8033fe:	8b 74 24 34          	mov    0x34(%esp),%esi
  803402:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803406:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80340a:	89 c7                	mov    %eax,%edi
  80340c:	89 f2                	mov    %esi,%edx
  80340e:	85 ed                	test   %ebp,%ebp
  803410:	75 16                	jne    803428 <__umoddi3+0x3c>
  803412:	39 f1                	cmp    %esi,%ecx
  803414:	0f 86 a6 00 00 00    	jbe    8034c0 <__umoddi3+0xd4>
  80341a:	f7 f1                	div    %ecx
  80341c:	89 d0                	mov    %edx,%eax
  80341e:	31 d2                	xor    %edx,%edx
  803420:	83 c4 20             	add    $0x20,%esp
  803423:	5e                   	pop    %esi
  803424:	5f                   	pop    %edi
  803425:	5d                   	pop    %ebp
  803426:	c3                   	ret    
  803427:	90                   	nop
  803428:	39 f5                	cmp    %esi,%ebp
  80342a:	0f 87 ac 00 00 00    	ja     8034dc <__umoddi3+0xf0>
  803430:	0f bd c5             	bsr    %ebp,%eax
  803433:	83 f0 1f             	xor    $0x1f,%eax
  803436:	89 44 24 10          	mov    %eax,0x10(%esp)
  80343a:	0f 84 a8 00 00 00    	je     8034e8 <__umoddi3+0xfc>
  803440:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803444:	d3 e5                	shl    %cl,%ebp
  803446:	bf 20 00 00 00       	mov    $0x20,%edi
  80344b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80344f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803453:	89 f9                	mov    %edi,%ecx
  803455:	d3 e8                	shr    %cl,%eax
  803457:	09 e8                	or     %ebp,%eax
  803459:	89 44 24 18          	mov    %eax,0x18(%esp)
  80345d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803461:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803465:	d3 e0                	shl    %cl,%eax
  803467:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80346b:	89 f2                	mov    %esi,%edx
  80346d:	d3 e2                	shl    %cl,%edx
  80346f:	8b 44 24 14          	mov    0x14(%esp),%eax
  803473:	d3 e0                	shl    %cl,%eax
  803475:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  803479:	8b 44 24 14          	mov    0x14(%esp),%eax
  80347d:	89 f9                	mov    %edi,%ecx
  80347f:	d3 e8                	shr    %cl,%eax
  803481:	09 d0                	or     %edx,%eax
  803483:	d3 ee                	shr    %cl,%esi
  803485:	89 f2                	mov    %esi,%edx
  803487:	f7 74 24 18          	divl   0x18(%esp)
  80348b:	89 d6                	mov    %edx,%esi
  80348d:	f7 64 24 0c          	mull   0xc(%esp)
  803491:	89 c5                	mov    %eax,%ebp
  803493:	89 d1                	mov    %edx,%ecx
  803495:	39 d6                	cmp    %edx,%esi
  803497:	72 67                	jb     803500 <__umoddi3+0x114>
  803499:	74 75                	je     803510 <__umoddi3+0x124>
  80349b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80349f:	29 e8                	sub    %ebp,%eax
  8034a1:	19 ce                	sbb    %ecx,%esi
  8034a3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8034a7:	d3 e8                	shr    %cl,%eax
  8034a9:	89 f2                	mov    %esi,%edx
  8034ab:	89 f9                	mov    %edi,%ecx
  8034ad:	d3 e2                	shl    %cl,%edx
  8034af:	09 d0                	or     %edx,%eax
  8034b1:	89 f2                	mov    %esi,%edx
  8034b3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8034b7:	d3 ea                	shr    %cl,%edx
  8034b9:	83 c4 20             	add    $0x20,%esp
  8034bc:	5e                   	pop    %esi
  8034bd:	5f                   	pop    %edi
  8034be:	5d                   	pop    %ebp
  8034bf:	c3                   	ret    
  8034c0:	85 c9                	test   %ecx,%ecx
  8034c2:	75 0b                	jne    8034cf <__umoddi3+0xe3>
  8034c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8034c9:	31 d2                	xor    %edx,%edx
  8034cb:	f7 f1                	div    %ecx
  8034cd:	89 c1                	mov    %eax,%ecx
  8034cf:	89 f0                	mov    %esi,%eax
  8034d1:	31 d2                	xor    %edx,%edx
  8034d3:	f7 f1                	div    %ecx
  8034d5:	89 f8                	mov    %edi,%eax
  8034d7:	e9 3e ff ff ff       	jmp    80341a <__umoddi3+0x2e>
  8034dc:	89 f2                	mov    %esi,%edx
  8034de:	83 c4 20             	add    $0x20,%esp
  8034e1:	5e                   	pop    %esi
  8034e2:	5f                   	pop    %edi
  8034e3:	5d                   	pop    %ebp
  8034e4:	c3                   	ret    
  8034e5:	8d 76 00             	lea    0x0(%esi),%esi
  8034e8:	39 f5                	cmp    %esi,%ebp
  8034ea:	72 04                	jb     8034f0 <__umoddi3+0x104>
  8034ec:	39 f9                	cmp    %edi,%ecx
  8034ee:	77 06                	ja     8034f6 <__umoddi3+0x10a>
  8034f0:	89 f2                	mov    %esi,%edx
  8034f2:	29 cf                	sub    %ecx,%edi
  8034f4:	19 ea                	sbb    %ebp,%edx
  8034f6:	89 f8                	mov    %edi,%eax
  8034f8:	83 c4 20             	add    $0x20,%esp
  8034fb:	5e                   	pop    %esi
  8034fc:	5f                   	pop    %edi
  8034fd:	5d                   	pop    %ebp
  8034fe:	c3                   	ret    
  8034ff:	90                   	nop
  803500:	89 d1                	mov    %edx,%ecx
  803502:	89 c5                	mov    %eax,%ebp
  803504:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  803508:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80350c:	eb 8d                	jmp    80349b <__umoddi3+0xaf>
  80350e:	66 90                	xchg   %ax,%ax
  803510:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  803514:	72 ea                	jb     803500 <__umoddi3+0x114>
  803516:	89 f1                	mov    %esi,%ecx
  803518:	eb 81                	jmp    80349b <__umoddi3+0xaf>

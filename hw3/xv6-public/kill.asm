
_kill:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 e4 f0             	and    $0xfffffff0,%esp
   9:	83 ec 10             	sub    $0x10,%esp
   c:	8b 75 08             	mov    0x8(%ebp),%esi
   f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  if(argc < 2){
  12:	83 fe 01             	cmp    $0x1,%esi
  15:	7e 22                	jle    39 <main+0x39>
  17:	bb 01 00 00 00       	mov    $0x1,%ebx
    printf(2, "usage: kill pid...\n");
    exit();
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  1c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  1f:	89 04 24             	mov    %eax,(%esp)
  22:	e8 95 01 00 00       	call   1bc <atoi>
  27:	89 04 24             	mov    %eax,(%esp)
  2a:	e8 19 02 00 00       	call   248 <kill>

  if(argc < 2){
    printf(2, "usage: kill pid...\n");
    exit();
  }
  for(i=1; i<argc; i++)
  2f:	43                   	inc    %ebx
  30:	39 f3                	cmp    %esi,%ebx
  32:	75 e8                	jne    1c <main+0x1c>
    kill(atoi(argv[i]));
  exit();
  34:	e8 df 01 00 00       	call   218 <exit>
main(int argc, char **argv)
{
  int i;

  if(argc < 2){
    printf(2, "usage: kill pid...\n");
  39:	c7 44 24 04 e2 05 00 	movl   $0x5e2,0x4(%esp)
  40:	00 
  41:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  48:	e8 03 03 00 00       	call   350 <printf>
    exit();
  4d:	e8 c6 01 00 00       	call   218 <exit>
  52:	90                   	nop
  53:	90                   	nop

00000054 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  54:	55                   	push   %ebp
  55:	89 e5                	mov    %esp,%ebp
  57:	53                   	push   %ebx
  58:	8b 45 08             	mov    0x8(%ebp),%eax
  5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  5e:	31 d2                	xor    %edx,%edx
  60:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  63:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  66:	42                   	inc    %edx
  67:	84 c9                	test   %cl,%cl
  69:	75 f5                	jne    60 <strcpy+0xc>
    ;
  return os;
}
  6b:	5b                   	pop    %ebx
  6c:	5d                   	pop    %ebp
  6d:	c3                   	ret    
  6e:	66 90                	xchg   %ax,%ax

00000070 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  70:	55                   	push   %ebp
  71:	89 e5                	mov    %esp,%ebp
  73:	56                   	push   %esi
  74:	53                   	push   %ebx
  75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  78:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  7b:	8a 01                	mov    (%ecx),%al
  7d:	8a 1a                	mov    (%edx),%bl
  7f:	84 c0                	test   %al,%al
  81:	74 1d                	je     a0 <strcmp+0x30>
  83:	38 d8                	cmp    %bl,%al
  85:	74 0c                	je     93 <strcmp+0x23>
  87:	eb 23                	jmp    ac <strcmp+0x3c>
  89:	8d 76 00             	lea    0x0(%esi),%esi
  8c:	41                   	inc    %ecx
  8d:	38 d8                	cmp    %bl,%al
  8f:	75 1b                	jne    ac <strcmp+0x3c>
    p++, q++;
  91:	89 f2                	mov    %esi,%edx
  93:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  96:	8a 41 01             	mov    0x1(%ecx),%al
  99:	8a 5a 01             	mov    0x1(%edx),%bl
  9c:	84 c0                	test   %al,%al
  9e:	75 ec                	jne    8c <strcmp+0x1c>
  a0:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
  a2:	0f b6 db             	movzbl %bl,%ebx
  a5:	29 d8                	sub    %ebx,%eax
}
  a7:	5b                   	pop    %ebx
  a8:	5e                   	pop    %esi
  a9:	5d                   	pop    %ebp
  aa:	c3                   	ret    
  ab:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ac:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
  af:	0f b6 db             	movzbl %bl,%ebx
  b2:	29 d8                	sub    %ebx,%eax
}
  b4:	5b                   	pop    %ebx
  b5:	5e                   	pop    %esi
  b6:	5d                   	pop    %ebp
  b7:	c3                   	ret    

000000b8 <strlen>:

uint
strlen(const char *s)
{
  b8:	55                   	push   %ebp
  b9:	89 e5                	mov    %esp,%ebp
  bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  be:	80 39 00             	cmpb   $0x0,(%ecx)
  c1:	74 10                	je     d3 <strlen+0x1b>
  c3:	31 d2                	xor    %edx,%edx
  c5:	8d 76 00             	lea    0x0(%esi),%esi
  c8:	42                   	inc    %edx
  c9:	89 d0                	mov    %edx,%eax
  cb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  cf:	75 f7                	jne    c8 <strlen+0x10>
    ;
  return n;
}
  d1:	5d                   	pop    %ebp
  d2:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
  d3:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
  d5:	5d                   	pop    %ebp
  d6:	c3                   	ret    
  d7:	90                   	nop

000000d8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d8:	55                   	push   %ebp
  d9:	89 e5                	mov    %esp,%ebp
  db:	57                   	push   %edi
  dc:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  df:	89 d7                	mov    %edx,%edi
  e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  e7:	fc                   	cld    
  e8:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  ea:	89 d0                	mov    %edx,%eax
  ec:	5f                   	pop    %edi
  ed:	5d                   	pop    %ebp
  ee:	c3                   	ret    
  ef:	90                   	nop

000000f0 <strchr>:

char*
strchr(const char *s, char c)
{
  f0:	55                   	push   %ebp
  f1:	89 e5                	mov    %esp,%ebp
  f3:	8b 45 08             	mov    0x8(%ebp),%eax
  f6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
  f9:	8a 10                	mov    (%eax),%dl
  fb:	84 d2                	test   %dl,%dl
  fd:	75 0d                	jne    10c <strchr+0x1c>
  ff:	eb 13                	jmp    114 <strchr+0x24>
 101:	8d 76 00             	lea    0x0(%esi),%esi
 104:	8a 50 01             	mov    0x1(%eax),%dl
 107:	84 d2                	test   %dl,%dl
 109:	74 09                	je     114 <strchr+0x24>
 10b:	40                   	inc    %eax
    if(*s == c)
 10c:	38 ca                	cmp    %cl,%dl
 10e:	75 f4                	jne    104 <strchr+0x14>
      return (char*)s;
  return 0;
}
 110:	5d                   	pop    %ebp
 111:	c3                   	ret    
 112:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
 114:	31 c0                	xor    %eax,%eax
}
 116:	5d                   	pop    %ebp
 117:	c3                   	ret    

00000118 <gets>:

char*
gets(char *buf, int max)
{
 118:	55                   	push   %ebp
 119:	89 e5                	mov    %esp,%ebp
 11b:	57                   	push   %edi
 11c:	56                   	push   %esi
 11d:	53                   	push   %ebx
 11e:	83 ec 2c             	sub    $0x2c,%esp
 121:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 124:	31 f6                	xor    %esi,%esi
 126:	eb 30                	jmp    158 <gets+0x40>
    cc = read(0, &c, 1);
 128:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 12f:	00 
 130:	8d 45 e7             	lea    -0x19(%ebp),%eax
 133:	89 44 24 04          	mov    %eax,0x4(%esp)
 137:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 13e:	e8 ed 00 00 00       	call   230 <read>
    if(cc < 1)
 143:	85 c0                	test   %eax,%eax
 145:	7e 19                	jle    160 <gets+0x48>
      break;
    buf[i++] = c;
 147:	8a 45 e7             	mov    -0x19(%ebp),%al
 14a:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 14e:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 150:	3c 0a                	cmp    $0xa,%al
 152:	74 0c                	je     160 <gets+0x48>
 154:	3c 0d                	cmp    $0xd,%al
 156:	74 08                	je     160 <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 158:	8d 5e 01             	lea    0x1(%esi),%ebx
 15b:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 15e:	7c c8                	jl     128 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 160:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 164:	89 f8                	mov    %edi,%eax
 166:	83 c4 2c             	add    $0x2c,%esp
 169:	5b                   	pop    %ebx
 16a:	5e                   	pop    %esi
 16b:	5f                   	pop    %edi
 16c:	5d                   	pop    %ebp
 16d:	c3                   	ret    
 16e:	66 90                	xchg   %ax,%ax

00000170 <stat>:

int
stat(const char *n, struct stat *st)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	56                   	push   %esi
 174:	53                   	push   %ebx
 175:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 178:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 17f:	00 
 180:	8b 45 08             	mov    0x8(%ebp),%eax
 183:	89 04 24             	mov    %eax,(%esp)
 186:	e8 cd 00 00 00       	call   258 <open>
 18b:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 18d:	85 c0                	test   %eax,%eax
 18f:	78 23                	js     1b4 <stat+0x44>
    return -1;
  r = fstat(fd, st);
 191:	8b 45 0c             	mov    0xc(%ebp),%eax
 194:	89 44 24 04          	mov    %eax,0x4(%esp)
 198:	89 1c 24             	mov    %ebx,(%esp)
 19b:	e8 d0 00 00 00       	call   270 <fstat>
 1a0:	89 c6                	mov    %eax,%esi
  close(fd);
 1a2:	89 1c 24             	mov    %ebx,(%esp)
 1a5:	e8 96 00 00 00       	call   240 <close>
  return r;
}
 1aa:	89 f0                	mov    %esi,%eax
 1ac:	83 c4 10             	add    $0x10,%esp
 1af:	5b                   	pop    %ebx
 1b0:	5e                   	pop    %esi
 1b1:	5d                   	pop    %ebp
 1b2:	c3                   	ret    
 1b3:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 1b4:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1b9:	eb ef                	jmp    1aa <stat+0x3a>
 1bb:	90                   	nop

000001bc <atoi>:
  return r;
}

int
atoi(const char *s)
{
 1bc:	55                   	push   %ebp
 1bd:	89 e5                	mov    %esp,%ebp
 1bf:	53                   	push   %ebx
 1c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1c3:	8a 11                	mov    (%ecx),%dl
 1c5:	8d 42 d0             	lea    -0x30(%edx),%eax
 1c8:	3c 09                	cmp    $0x9,%al
 1ca:	b8 00 00 00 00       	mov    $0x0,%eax
 1cf:	77 18                	ja     1e9 <atoi+0x2d>
 1d1:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 1d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
 1d7:	0f be d2             	movsbl %dl,%edx
 1da:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 1de:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1df:	8a 11                	mov    (%ecx),%dl
 1e1:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1e4:	80 fb 09             	cmp    $0x9,%bl
 1e7:	76 eb                	jbe    1d4 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 1e9:	5b                   	pop    %ebx
 1ea:	5d                   	pop    %ebp
 1eb:	c3                   	ret    

000001ec <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1ec:	55                   	push   %ebp
 1ed:	89 e5                	mov    %esp,%ebp
 1ef:	56                   	push   %esi
 1f0:	53                   	push   %ebx
 1f1:	8b 45 08             	mov    0x8(%ebp),%eax
 1f4:	8b 75 0c             	mov    0xc(%ebp),%esi
 1f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 1fa:	85 db                	test   %ebx,%ebx
 1fc:	7e 0d                	jle    20b <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 1fe:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 200:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 203:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 206:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 207:	39 da                	cmp    %ebx,%edx
 209:	75 f5                	jne    200 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 20b:	5b                   	pop    %ebx
 20c:	5e                   	pop    %esi
 20d:	5d                   	pop    %ebp
 20e:	c3                   	ret    
 20f:	90                   	nop

00000210 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 210:	b8 01 00 00 00       	mov    $0x1,%eax
 215:	cd 40                	int    $0x40
 217:	c3                   	ret    

00000218 <exit>:
SYSCALL(exit)
 218:	b8 02 00 00 00       	mov    $0x2,%eax
 21d:	cd 40                	int    $0x40
 21f:	c3                   	ret    

00000220 <wait>:
SYSCALL(wait)
 220:	b8 03 00 00 00       	mov    $0x3,%eax
 225:	cd 40                	int    $0x40
 227:	c3                   	ret    

00000228 <pipe>:
SYSCALL(pipe)
 228:	b8 04 00 00 00       	mov    $0x4,%eax
 22d:	cd 40                	int    $0x40
 22f:	c3                   	ret    

00000230 <read>:
SYSCALL(read)
 230:	b8 05 00 00 00       	mov    $0x5,%eax
 235:	cd 40                	int    $0x40
 237:	c3                   	ret    

00000238 <write>:
SYSCALL(write)
 238:	b8 10 00 00 00       	mov    $0x10,%eax
 23d:	cd 40                	int    $0x40
 23f:	c3                   	ret    

00000240 <close>:
SYSCALL(close)
 240:	b8 15 00 00 00       	mov    $0x15,%eax
 245:	cd 40                	int    $0x40
 247:	c3                   	ret    

00000248 <kill>:
SYSCALL(kill)
 248:	b8 06 00 00 00       	mov    $0x6,%eax
 24d:	cd 40                	int    $0x40
 24f:	c3                   	ret    

00000250 <exec>:
SYSCALL(exec)
 250:	b8 07 00 00 00       	mov    $0x7,%eax
 255:	cd 40                	int    $0x40
 257:	c3                   	ret    

00000258 <open>:
SYSCALL(open)
 258:	b8 0f 00 00 00       	mov    $0xf,%eax
 25d:	cd 40                	int    $0x40
 25f:	c3                   	ret    

00000260 <mknod>:
SYSCALL(mknod)
 260:	b8 11 00 00 00       	mov    $0x11,%eax
 265:	cd 40                	int    $0x40
 267:	c3                   	ret    

00000268 <unlink>:
SYSCALL(unlink)
 268:	b8 12 00 00 00       	mov    $0x12,%eax
 26d:	cd 40                	int    $0x40
 26f:	c3                   	ret    

00000270 <fstat>:
SYSCALL(fstat)
 270:	b8 08 00 00 00       	mov    $0x8,%eax
 275:	cd 40                	int    $0x40
 277:	c3                   	ret    

00000278 <link>:
SYSCALL(link)
 278:	b8 13 00 00 00       	mov    $0x13,%eax
 27d:	cd 40                	int    $0x40
 27f:	c3                   	ret    

00000280 <mkdir>:
SYSCALL(mkdir)
 280:	b8 14 00 00 00       	mov    $0x14,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <chdir>:
SYSCALL(chdir)
 288:	b8 09 00 00 00       	mov    $0x9,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <dup>:
SYSCALL(dup)
 290:	b8 0a 00 00 00       	mov    $0xa,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <getpid>:
SYSCALL(getpid)
 298:	b8 0b 00 00 00       	mov    $0xb,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <sbrk>:
SYSCALL(sbrk)
 2a0:	b8 0c 00 00 00       	mov    $0xc,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <sleep>:
SYSCALL(sleep)
 2a8:	b8 0d 00 00 00       	mov    $0xd,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <uptime>:
SYSCALL(uptime)
 2b0:	b8 0e 00 00 00       	mov    $0xe,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <date>:
SYSCALL(date)
 2b8:	b8 16 00 00 00       	mov    $0x16,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2c0:	55                   	push   %ebp
 2c1:	89 e5                	mov    %esp,%ebp
 2c3:	83 ec 28             	sub    $0x28,%esp
 2c6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2c9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2d0:	00 
 2d1:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2d4:	89 54 24 04          	mov    %edx,0x4(%esp)
 2d8:	89 04 24             	mov    %eax,(%esp)
 2db:	e8 58 ff ff ff       	call   238 <write>
}
 2e0:	c9                   	leave  
 2e1:	c3                   	ret    
 2e2:	66 90                	xchg   %ax,%ax

000002e4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2e4:	55                   	push   %ebp
 2e5:	89 e5                	mov    %esp,%ebp
 2e7:	57                   	push   %edi
 2e8:	56                   	push   %esi
 2e9:	53                   	push   %ebx
 2ea:	83 ec 1c             	sub    $0x1c,%esp
 2ed:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 2ef:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
 2f4:	85 db                	test   %ebx,%ebx
 2f6:	74 04                	je     2fc <printint+0x18>
 2f8:	85 d2                	test   %edx,%edx
 2fa:	78 4a                	js     346 <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 2fc:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 2fe:	31 db                	xor    %ebx,%ebx
 300:	eb 04                	jmp    306 <printint+0x22>
 302:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 304:	89 d3                	mov    %edx,%ebx
 306:	31 d2                	xor    %edx,%edx
 308:	f7 f1                	div    %ecx
 30a:	8a 92 fd 05 00 00    	mov    0x5fd(%edx),%dl
 310:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 314:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 317:	85 c0                	test   %eax,%eax
 319:	75 e9                	jne    304 <printint+0x20>
  if(neg)
 31b:	85 ff                	test   %edi,%edi
 31d:	74 08                	je     327 <printint+0x43>
    buf[i++] = '-';
 31f:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 324:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 327:	8d 5a ff             	lea    -0x1(%edx),%ebx
 32a:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 32c:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 331:	89 f0                	mov    %esi,%eax
 333:	e8 88 ff ff ff       	call   2c0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 338:	4b                   	dec    %ebx
 339:	83 fb ff             	cmp    $0xffffffff,%ebx
 33c:	75 ee                	jne    32c <printint+0x48>
    putc(fd, buf[i]);
}
 33e:	83 c4 1c             	add    $0x1c,%esp
 341:	5b                   	pop    %ebx
 342:	5e                   	pop    %esi
 343:	5f                   	pop    %edi
 344:	5d                   	pop    %ebp
 345:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 346:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 348:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 34d:	eb af                	jmp    2fe <printint+0x1a>
 34f:	90                   	nop

00000350 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 350:	55                   	push   %ebp
 351:	89 e5                	mov    %esp,%ebp
 353:	57                   	push   %edi
 354:	56                   	push   %esi
 355:	53                   	push   %ebx
 356:	83 ec 2c             	sub    $0x2c,%esp
 359:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 35c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 35f:	8a 0b                	mov    (%ebx),%cl
 361:	84 c9                	test   %cl,%cl
 363:	74 7b                	je     3e0 <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 365:	8d 45 10             	lea    0x10(%ebp),%eax
 368:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 36b:	31 f6                	xor    %esi,%esi
 36d:	eb 17                	jmp    386 <printf+0x36>
 36f:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 370:	83 f9 25             	cmp    $0x25,%ecx
 373:	74 73                	je     3e8 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 375:	0f be d1             	movsbl %cl,%edx
 378:	89 f8                	mov    %edi,%eax
 37a:	e8 41 ff ff ff       	call   2c0 <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 37f:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 380:	8a 0b                	mov    (%ebx),%cl
 382:	84 c9                	test   %cl,%cl
 384:	74 5a                	je     3e0 <printf+0x90>
    c = fmt[i] & 0xff;
 386:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 389:	85 f6                	test   %esi,%esi
 38b:	74 e3                	je     370 <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 38d:	83 fe 25             	cmp    $0x25,%esi
 390:	75 ed                	jne    37f <printf+0x2f>
      if(c == 'd'){
 392:	83 f9 64             	cmp    $0x64,%ecx
 395:	0f 84 c1 00 00 00    	je     45c <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 39b:	83 f9 78             	cmp    $0x78,%ecx
 39e:	74 50                	je     3f0 <printf+0xa0>
 3a0:	83 f9 70             	cmp    $0x70,%ecx
 3a3:	74 4b                	je     3f0 <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3a5:	83 f9 73             	cmp    $0x73,%ecx
 3a8:	74 6a                	je     414 <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3aa:	83 f9 63             	cmp    $0x63,%ecx
 3ad:	0f 84 91 00 00 00    	je     444 <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 3b3:	ba 25 00 00 00       	mov    $0x25,%edx
 3b8:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3ba:	83 f9 25             	cmp    $0x25,%ecx
 3bd:	74 10                	je     3cf <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3bf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 3c2:	e8 f9 fe ff ff       	call   2c0 <putc>
        putc(fd, c);
 3c7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 3ca:	0f be d1             	movsbl %cl,%edx
 3cd:	89 f8                	mov    %edi,%eax
 3cf:	e8 ec fe ff ff       	call   2c0 <putc>
      }
      state = 0;
 3d4:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 3d6:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3d7:	8a 0b                	mov    (%ebx),%cl
 3d9:	84 c9                	test   %cl,%cl
 3db:	75 a9                	jne    386 <printf+0x36>
 3dd:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 3e0:	83 c4 2c             	add    $0x2c,%esp
 3e3:	5b                   	pop    %ebx
 3e4:	5e                   	pop    %esi
 3e5:	5f                   	pop    %edi
 3e6:	5d                   	pop    %ebp
 3e7:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 3e8:	be 25 00 00 00       	mov    $0x25,%esi
 3ed:	eb 90                	jmp    37f <printf+0x2f>
 3ef:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 3f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 3f7:	b9 10 00 00 00       	mov    $0x10,%ecx
 3fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3ff:	8b 10                	mov    (%eax),%edx
 401:	89 f8                	mov    %edi,%eax
 403:	e8 dc fe ff ff       	call   2e4 <printint>
        ap++;
 408:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 40c:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 40e:	e9 6c ff ff ff       	jmp    37f <printf+0x2f>
 413:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 414:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 417:	8b 30                	mov    (%eax),%esi
        ap++;
 419:	83 c0 04             	add    $0x4,%eax
 41c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 41f:	85 f6                	test   %esi,%esi
 421:	74 5a                	je     47d <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 423:	8a 16                	mov    (%esi),%dl
 425:	84 d2                	test   %dl,%dl
 427:	74 14                	je     43d <printf+0xed>
 429:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 42c:	0f be d2             	movsbl %dl,%edx
 42f:	89 f8                	mov    %edi,%eax
 431:	e8 8a fe ff ff       	call   2c0 <putc>
          s++;
 436:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 437:	8a 16                	mov    (%esi),%dl
 439:	84 d2                	test   %dl,%dl
 43b:	75 ef                	jne    42c <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 43d:	31 f6                	xor    %esi,%esi
 43f:	e9 3b ff ff ff       	jmp    37f <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 444:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 447:	0f be 10             	movsbl (%eax),%edx
 44a:	89 f8                	mov    %edi,%eax
 44c:	e8 6f fe ff ff       	call   2c0 <putc>
        ap++;
 451:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 455:	31 f6                	xor    %esi,%esi
 457:	e9 23 ff ff ff       	jmp    37f <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 45c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 463:	b1 0a                	mov    $0xa,%cl
 465:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 468:	8b 10                	mov    (%eax),%edx
 46a:	89 f8                	mov    %edi,%eax
 46c:	e8 73 fe ff ff       	call   2e4 <printint>
        ap++;
 471:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 475:	66 31 f6             	xor    %si,%si
 478:	e9 02 ff ff ff       	jmp    37f <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 47d:	be f6 05 00 00       	mov    $0x5f6,%esi
 482:	eb 9f                	jmp    423 <printf+0xd3>

00000484 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 484:	55                   	push   %ebp
 485:	89 e5                	mov    %esp,%ebp
 487:	57                   	push   %edi
 488:	56                   	push   %esi
 489:	53                   	push   %ebx
 48a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 48d:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 490:	a1 b4 08 00 00       	mov    0x8b4,%eax
 495:	8d 76 00             	lea    0x0(%esi),%esi
 498:	8b 10                	mov    (%eax),%edx
 49a:	39 c8                	cmp    %ecx,%eax
 49c:	73 04                	jae    4a2 <free+0x1e>
 49e:	39 d1                	cmp    %edx,%ecx
 4a0:	72 12                	jb     4b4 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4a2:	39 d0                	cmp    %edx,%eax
 4a4:	72 08                	jb     4ae <free+0x2a>
 4a6:	39 c8                	cmp    %ecx,%eax
 4a8:	72 0a                	jb     4b4 <free+0x30>
 4aa:	39 d1                	cmp    %edx,%ecx
 4ac:	72 06                	jb     4b4 <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 4ae:	89 d0                	mov    %edx,%eax
 4b0:	eb e6                	jmp    498 <free+0x14>
 4b2:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 4b4:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4b7:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4ba:	39 d7                	cmp    %edx,%edi
 4bc:	74 19                	je     4d7 <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4be:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4c1:	8b 50 04             	mov    0x4(%eax),%edx
 4c4:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4c7:	39 f1                	cmp    %esi,%ecx
 4c9:	74 23                	je     4ee <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4cb:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4cd:	a3 b4 08 00 00       	mov    %eax,0x8b4
}
 4d2:	5b                   	pop    %ebx
 4d3:	5e                   	pop    %esi
 4d4:	5f                   	pop    %edi
 4d5:	5d                   	pop    %ebp
 4d6:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 4d7:	03 72 04             	add    0x4(%edx),%esi
 4da:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4dd:	8b 10                	mov    (%eax),%edx
 4df:	8b 12                	mov    (%edx),%edx
 4e1:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 4e4:	8b 50 04             	mov    0x4(%eax),%edx
 4e7:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4ea:	39 f1                	cmp    %esi,%ecx
 4ec:	75 dd                	jne    4cb <free+0x47>
    p->s.size += bp->s.size;
 4ee:	03 53 fc             	add    -0x4(%ebx),%edx
 4f1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4f4:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4f7:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 4f9:	a3 b4 08 00 00       	mov    %eax,0x8b4
}
 4fe:	5b                   	pop    %ebx
 4ff:	5e                   	pop    %esi
 500:	5f                   	pop    %edi
 501:	5d                   	pop    %ebp
 502:	c3                   	ret    
 503:	90                   	nop

00000504 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 504:	55                   	push   %ebp
 505:	89 e5                	mov    %esp,%ebp
 507:	57                   	push   %edi
 508:	56                   	push   %esi
 509:	53                   	push   %ebx
 50a:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 50d:	8b 5d 08             	mov    0x8(%ebp),%ebx
 510:	83 c3 07             	add    $0x7,%ebx
 513:	c1 eb 03             	shr    $0x3,%ebx
 516:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 517:	8b 0d b4 08 00 00    	mov    0x8b4,%ecx
 51d:	85 c9                	test   %ecx,%ecx
 51f:	0f 84 95 00 00 00    	je     5ba <malloc+0xb6>
 525:	8b 01                	mov    (%ecx),%eax
 527:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 52a:	39 da                	cmp    %ebx,%edx
 52c:	73 66                	jae    594 <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 52e:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 535:	eb 0c                	jmp    543 <malloc+0x3f>
 537:	90                   	nop
    }
    if(p == freep)
 538:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 53a:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 53c:	8b 50 04             	mov    0x4(%eax),%edx
 53f:	39 d3                	cmp    %edx,%ebx
 541:	76 51                	jbe    594 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 543:	3b 05 b4 08 00 00    	cmp    0x8b4,%eax
 549:	75 ed                	jne    538 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 54b:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 551:	76 35                	jbe    588 <malloc+0x84>
 553:	89 f8                	mov    %edi,%eax
 555:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 557:	89 04 24             	mov    %eax,(%esp)
 55a:	e8 41 fd ff ff       	call   2a0 <sbrk>
  if(p == (char*)-1)
 55f:	83 f8 ff             	cmp    $0xffffffff,%eax
 562:	74 18                	je     57c <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 564:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 567:	83 c0 08             	add    $0x8,%eax
 56a:	89 04 24             	mov    %eax,(%esp)
 56d:	e8 12 ff ff ff       	call   484 <free>
  return freep;
 572:	8b 0d b4 08 00 00    	mov    0x8b4,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 578:	85 c9                	test   %ecx,%ecx
 57a:	75 be                	jne    53a <malloc+0x36>
        return 0;
 57c:	31 c0                	xor    %eax,%eax
  }
}
 57e:	83 c4 1c             	add    $0x1c,%esp
 581:	5b                   	pop    %ebx
 582:	5e                   	pop    %esi
 583:	5f                   	pop    %edi
 584:	5d                   	pop    %ebp
 585:	c3                   	ret    
 586:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 588:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 58d:	be 00 10 00 00       	mov    $0x1000,%esi
 592:	eb c3                	jmp    557 <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 594:	39 d3                	cmp    %edx,%ebx
 596:	74 1c                	je     5b4 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 598:	29 da                	sub    %ebx,%edx
 59a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 59d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5a0:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5a3:	89 0d b4 08 00 00    	mov    %ecx,0x8b4
      return (void*)(p + 1);
 5a9:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5ac:	83 c4 1c             	add    $0x1c,%esp
 5af:	5b                   	pop    %ebx
 5b0:	5e                   	pop    %esi
 5b1:	5f                   	pop    %edi
 5b2:	5d                   	pop    %ebp
 5b3:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 5b4:	8b 10                	mov    (%eax),%edx
 5b6:	89 11                	mov    %edx,(%ecx)
 5b8:	eb e9                	jmp    5a3 <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 5ba:	c7 05 b4 08 00 00 b8 	movl   $0x8b8,0x8b4
 5c1:	08 00 00 
 5c4:	c7 05 b8 08 00 00 b8 	movl   $0x8b8,0x8b8
 5cb:	08 00 00 
    base.s.size = 0;
 5ce:	c7 05 bc 08 00 00 00 	movl   $0x0,0x8bc
 5d5:	00 00 00 
 5d8:	b8 b8 08 00 00       	mov    $0x8b8,%eax
 5dd:	e9 4c ff ff ff       	jmp    52e <malloc+0x2a>

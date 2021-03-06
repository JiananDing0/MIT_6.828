
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
  39:	c7 44 24 04 da 05 00 	movl   $0x5da,0x4(%esp)
  40:	00 
  41:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  48:	e8 fb 02 00 00       	call   348 <printf>
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

000002b8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2b8:	55                   	push   %ebp
 2b9:	89 e5                	mov    %esp,%ebp
 2bb:	83 ec 28             	sub    $0x28,%esp
 2be:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2c1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2c8:	00 
 2c9:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2cc:	89 54 24 04          	mov    %edx,0x4(%esp)
 2d0:	89 04 24             	mov    %eax,(%esp)
 2d3:	e8 60 ff ff ff       	call   238 <write>
}
 2d8:	c9                   	leave  
 2d9:	c3                   	ret    
 2da:	66 90                	xchg   %ax,%ax

000002dc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2dc:	55                   	push   %ebp
 2dd:	89 e5                	mov    %esp,%ebp
 2df:	57                   	push   %edi
 2e0:	56                   	push   %esi
 2e1:	53                   	push   %ebx
 2e2:	83 ec 1c             	sub    $0x1c,%esp
 2e5:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 2e7:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
 2ec:	85 db                	test   %ebx,%ebx
 2ee:	74 04                	je     2f4 <printint+0x18>
 2f0:	85 d2                	test   %edx,%edx
 2f2:	78 4a                	js     33e <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 2f4:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 2f6:	31 db                	xor    %ebx,%ebx
 2f8:	eb 04                	jmp    2fe <printint+0x22>
 2fa:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 2fc:	89 d3                	mov    %edx,%ebx
 2fe:	31 d2                	xor    %edx,%edx
 300:	f7 f1                	div    %ecx
 302:	8a 92 f5 05 00 00    	mov    0x5f5(%edx),%dl
 308:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 30c:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 30f:	85 c0                	test   %eax,%eax
 311:	75 e9                	jne    2fc <printint+0x20>
  if(neg)
 313:	85 ff                	test   %edi,%edi
 315:	74 08                	je     31f <printint+0x43>
    buf[i++] = '-';
 317:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 31c:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 31f:	8d 5a ff             	lea    -0x1(%edx),%ebx
 322:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 324:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 329:	89 f0                	mov    %esi,%eax
 32b:	e8 88 ff ff ff       	call   2b8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 330:	4b                   	dec    %ebx
 331:	83 fb ff             	cmp    $0xffffffff,%ebx
 334:	75 ee                	jne    324 <printint+0x48>
    putc(fd, buf[i]);
}
 336:	83 c4 1c             	add    $0x1c,%esp
 339:	5b                   	pop    %ebx
 33a:	5e                   	pop    %esi
 33b:	5f                   	pop    %edi
 33c:	5d                   	pop    %ebp
 33d:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 33e:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 340:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 345:	eb af                	jmp    2f6 <printint+0x1a>
 347:	90                   	nop

00000348 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 348:	55                   	push   %ebp
 349:	89 e5                	mov    %esp,%ebp
 34b:	57                   	push   %edi
 34c:	56                   	push   %esi
 34d:	53                   	push   %ebx
 34e:	83 ec 2c             	sub    $0x2c,%esp
 351:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 354:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 357:	8a 0b                	mov    (%ebx),%cl
 359:	84 c9                	test   %cl,%cl
 35b:	74 7b                	je     3d8 <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 35d:	8d 45 10             	lea    0x10(%ebp),%eax
 360:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 363:	31 f6                	xor    %esi,%esi
 365:	eb 17                	jmp    37e <printf+0x36>
 367:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 368:	83 f9 25             	cmp    $0x25,%ecx
 36b:	74 73                	je     3e0 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 36d:	0f be d1             	movsbl %cl,%edx
 370:	89 f8                	mov    %edi,%eax
 372:	e8 41 ff ff ff       	call   2b8 <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 377:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 378:	8a 0b                	mov    (%ebx),%cl
 37a:	84 c9                	test   %cl,%cl
 37c:	74 5a                	je     3d8 <printf+0x90>
    c = fmt[i] & 0xff;
 37e:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 381:	85 f6                	test   %esi,%esi
 383:	74 e3                	je     368 <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 385:	83 fe 25             	cmp    $0x25,%esi
 388:	75 ed                	jne    377 <printf+0x2f>
      if(c == 'd'){
 38a:	83 f9 64             	cmp    $0x64,%ecx
 38d:	0f 84 c1 00 00 00    	je     454 <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 393:	83 f9 78             	cmp    $0x78,%ecx
 396:	74 50                	je     3e8 <printf+0xa0>
 398:	83 f9 70             	cmp    $0x70,%ecx
 39b:	74 4b                	je     3e8 <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 39d:	83 f9 73             	cmp    $0x73,%ecx
 3a0:	74 6a                	je     40c <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3a2:	83 f9 63             	cmp    $0x63,%ecx
 3a5:	0f 84 91 00 00 00    	je     43c <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 3ab:	ba 25 00 00 00       	mov    $0x25,%edx
 3b0:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3b2:	83 f9 25             	cmp    $0x25,%ecx
 3b5:	74 10                	je     3c7 <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3b7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 3ba:	e8 f9 fe ff ff       	call   2b8 <putc>
        putc(fd, c);
 3bf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 3c2:	0f be d1             	movsbl %cl,%edx
 3c5:	89 f8                	mov    %edi,%eax
 3c7:	e8 ec fe ff ff       	call   2b8 <putc>
      }
      state = 0;
 3cc:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 3ce:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3cf:	8a 0b                	mov    (%ebx),%cl
 3d1:	84 c9                	test   %cl,%cl
 3d3:	75 a9                	jne    37e <printf+0x36>
 3d5:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 3d8:	83 c4 2c             	add    $0x2c,%esp
 3db:	5b                   	pop    %ebx
 3dc:	5e                   	pop    %esi
 3dd:	5f                   	pop    %edi
 3de:	5d                   	pop    %ebp
 3df:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 3e0:	be 25 00 00 00       	mov    $0x25,%esi
 3e5:	eb 90                	jmp    377 <printf+0x2f>
 3e7:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 3e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 3ef:	b9 10 00 00 00       	mov    $0x10,%ecx
 3f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3f7:	8b 10                	mov    (%eax),%edx
 3f9:	89 f8                	mov    %edi,%eax
 3fb:	e8 dc fe ff ff       	call   2dc <printint>
        ap++;
 400:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 404:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 406:	e9 6c ff ff ff       	jmp    377 <printf+0x2f>
 40b:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 40c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 40f:	8b 30                	mov    (%eax),%esi
        ap++;
 411:	83 c0 04             	add    $0x4,%eax
 414:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 417:	85 f6                	test   %esi,%esi
 419:	74 5a                	je     475 <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 41b:	8a 16                	mov    (%esi),%dl
 41d:	84 d2                	test   %dl,%dl
 41f:	74 14                	je     435 <printf+0xed>
 421:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 424:	0f be d2             	movsbl %dl,%edx
 427:	89 f8                	mov    %edi,%eax
 429:	e8 8a fe ff ff       	call   2b8 <putc>
          s++;
 42e:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 42f:	8a 16                	mov    (%esi),%dl
 431:	84 d2                	test   %dl,%dl
 433:	75 ef                	jne    424 <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 435:	31 f6                	xor    %esi,%esi
 437:	e9 3b ff ff ff       	jmp    377 <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 43c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 43f:	0f be 10             	movsbl (%eax),%edx
 442:	89 f8                	mov    %edi,%eax
 444:	e8 6f fe ff ff       	call   2b8 <putc>
        ap++;
 449:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 44d:	31 f6                	xor    %esi,%esi
 44f:	e9 23 ff ff ff       	jmp    377 <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 454:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 45b:	b1 0a                	mov    $0xa,%cl
 45d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 460:	8b 10                	mov    (%eax),%edx
 462:	89 f8                	mov    %edi,%eax
 464:	e8 73 fe ff ff       	call   2dc <printint>
        ap++;
 469:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 46d:	66 31 f6             	xor    %si,%si
 470:	e9 02 ff ff ff       	jmp    377 <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 475:	be ee 05 00 00       	mov    $0x5ee,%esi
 47a:	eb 9f                	jmp    41b <printf+0xd3>

0000047c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 47c:	55                   	push   %ebp
 47d:	89 e5                	mov    %esp,%ebp
 47f:	57                   	push   %edi
 480:	56                   	push   %esi
 481:	53                   	push   %ebx
 482:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 485:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 488:	a1 ac 08 00 00       	mov    0x8ac,%eax
 48d:	8d 76 00             	lea    0x0(%esi),%esi
 490:	8b 10                	mov    (%eax),%edx
 492:	39 c8                	cmp    %ecx,%eax
 494:	73 04                	jae    49a <free+0x1e>
 496:	39 d1                	cmp    %edx,%ecx
 498:	72 12                	jb     4ac <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 49a:	39 d0                	cmp    %edx,%eax
 49c:	72 08                	jb     4a6 <free+0x2a>
 49e:	39 c8                	cmp    %ecx,%eax
 4a0:	72 0a                	jb     4ac <free+0x30>
 4a2:	39 d1                	cmp    %edx,%ecx
 4a4:	72 06                	jb     4ac <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 4a6:	89 d0                	mov    %edx,%eax
 4a8:	eb e6                	jmp    490 <free+0x14>
 4aa:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 4ac:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4af:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4b2:	39 d7                	cmp    %edx,%edi
 4b4:	74 19                	je     4cf <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4b6:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4b9:	8b 50 04             	mov    0x4(%eax),%edx
 4bc:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4bf:	39 f1                	cmp    %esi,%ecx
 4c1:	74 23                	je     4e6 <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4c3:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4c5:	a3 ac 08 00 00       	mov    %eax,0x8ac
}
 4ca:	5b                   	pop    %ebx
 4cb:	5e                   	pop    %esi
 4cc:	5f                   	pop    %edi
 4cd:	5d                   	pop    %ebp
 4ce:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 4cf:	03 72 04             	add    0x4(%edx),%esi
 4d2:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4d5:	8b 10                	mov    (%eax),%edx
 4d7:	8b 12                	mov    (%edx),%edx
 4d9:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 4dc:	8b 50 04             	mov    0x4(%eax),%edx
 4df:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4e2:	39 f1                	cmp    %esi,%ecx
 4e4:	75 dd                	jne    4c3 <free+0x47>
    p->s.size += bp->s.size;
 4e6:	03 53 fc             	add    -0x4(%ebx),%edx
 4e9:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4ec:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4ef:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 4f1:	a3 ac 08 00 00       	mov    %eax,0x8ac
}
 4f6:	5b                   	pop    %ebx
 4f7:	5e                   	pop    %esi
 4f8:	5f                   	pop    %edi
 4f9:	5d                   	pop    %ebp
 4fa:	c3                   	ret    
 4fb:	90                   	nop

000004fc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 4fc:	55                   	push   %ebp
 4fd:	89 e5                	mov    %esp,%ebp
 4ff:	57                   	push   %edi
 500:	56                   	push   %esi
 501:	53                   	push   %ebx
 502:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 505:	8b 5d 08             	mov    0x8(%ebp),%ebx
 508:	83 c3 07             	add    $0x7,%ebx
 50b:	c1 eb 03             	shr    $0x3,%ebx
 50e:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 50f:	8b 0d ac 08 00 00    	mov    0x8ac,%ecx
 515:	85 c9                	test   %ecx,%ecx
 517:	0f 84 95 00 00 00    	je     5b2 <malloc+0xb6>
 51d:	8b 01                	mov    (%ecx),%eax
 51f:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 522:	39 da                	cmp    %ebx,%edx
 524:	73 66                	jae    58c <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 526:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 52d:	eb 0c                	jmp    53b <malloc+0x3f>
 52f:	90                   	nop
    }
    if(p == freep)
 530:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 532:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 534:	8b 50 04             	mov    0x4(%eax),%edx
 537:	39 d3                	cmp    %edx,%ebx
 539:	76 51                	jbe    58c <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 53b:	3b 05 ac 08 00 00    	cmp    0x8ac,%eax
 541:	75 ed                	jne    530 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 543:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 549:	76 35                	jbe    580 <malloc+0x84>
 54b:	89 f8                	mov    %edi,%eax
 54d:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 54f:	89 04 24             	mov    %eax,(%esp)
 552:	e8 49 fd ff ff       	call   2a0 <sbrk>
  if(p == (char*)-1)
 557:	83 f8 ff             	cmp    $0xffffffff,%eax
 55a:	74 18                	je     574 <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 55c:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 55f:	83 c0 08             	add    $0x8,%eax
 562:	89 04 24             	mov    %eax,(%esp)
 565:	e8 12 ff ff ff       	call   47c <free>
  return freep;
 56a:	8b 0d ac 08 00 00    	mov    0x8ac,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 570:	85 c9                	test   %ecx,%ecx
 572:	75 be                	jne    532 <malloc+0x36>
        return 0;
 574:	31 c0                	xor    %eax,%eax
  }
}
 576:	83 c4 1c             	add    $0x1c,%esp
 579:	5b                   	pop    %ebx
 57a:	5e                   	pop    %esi
 57b:	5f                   	pop    %edi
 57c:	5d                   	pop    %ebp
 57d:	c3                   	ret    
 57e:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 580:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 585:	be 00 10 00 00       	mov    $0x1000,%esi
 58a:	eb c3                	jmp    54f <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 58c:	39 d3                	cmp    %edx,%ebx
 58e:	74 1c                	je     5ac <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 590:	29 da                	sub    %ebx,%edx
 592:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 595:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 598:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 59b:	89 0d ac 08 00 00    	mov    %ecx,0x8ac
      return (void*)(p + 1);
 5a1:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5a4:	83 c4 1c             	add    $0x1c,%esp
 5a7:	5b                   	pop    %ebx
 5a8:	5e                   	pop    %esi
 5a9:	5f                   	pop    %edi
 5aa:	5d                   	pop    %ebp
 5ab:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 5ac:	8b 10                	mov    (%eax),%edx
 5ae:	89 11                	mov    %edx,(%ecx)
 5b0:	eb e9                	jmp    59b <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 5b2:	c7 05 ac 08 00 00 b0 	movl   $0x8b0,0x8ac
 5b9:	08 00 00 
 5bc:	c7 05 b0 08 00 00 b0 	movl   $0x8b0,0x8b0
 5c3:	08 00 00 
    base.s.size = 0;
 5c6:	c7 05 b4 08 00 00 00 	movl   $0x0,0x8b4
 5cd:	00 00 00 
 5d0:	b8 b0 08 00 00       	mov    $0x8b0,%eax
 5d5:	e9 4c ff ff ff       	jmp    526 <malloc+0x2a>

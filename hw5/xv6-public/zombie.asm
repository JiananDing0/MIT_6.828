
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(fork() > 0)
   9:	e8 d2 01 00 00       	call   1e0 <fork>
   e:	85 c0                	test   %eax,%eax
  10:	7e 0c                	jle    1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  12:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  19:	e8 5a 02 00 00       	call   278 <sleep>
  exit();
  1e:	e8 c5 01 00 00       	call   1e8 <exit>
  23:	90                   	nop

00000024 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  24:	55                   	push   %ebp
  25:	89 e5                	mov    %esp,%ebp
  27:	53                   	push   %ebx
  28:	8b 45 08             	mov    0x8(%ebp),%eax
  2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  2e:	31 d2                	xor    %edx,%edx
  30:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  33:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  36:	42                   	inc    %edx
  37:	84 c9                	test   %cl,%cl
  39:	75 f5                	jne    30 <strcpy+0xc>
    ;
  return os;
}
  3b:	5b                   	pop    %ebx
  3c:	5d                   	pop    %ebp
  3d:	c3                   	ret    
  3e:	66 90                	xchg   %ax,%ax

00000040 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  40:	55                   	push   %ebp
  41:	89 e5                	mov    %esp,%ebp
  43:	56                   	push   %esi
  44:	53                   	push   %ebx
  45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  48:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  4b:	8a 01                	mov    (%ecx),%al
  4d:	8a 1a                	mov    (%edx),%bl
  4f:	84 c0                	test   %al,%al
  51:	74 1d                	je     70 <strcmp+0x30>
  53:	38 d8                	cmp    %bl,%al
  55:	74 0c                	je     63 <strcmp+0x23>
  57:	eb 23                	jmp    7c <strcmp+0x3c>
  59:	8d 76 00             	lea    0x0(%esi),%esi
  5c:	41                   	inc    %ecx
  5d:	38 d8                	cmp    %bl,%al
  5f:	75 1b                	jne    7c <strcmp+0x3c>
    p++, q++;
  61:	89 f2                	mov    %esi,%edx
  63:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  66:	8a 41 01             	mov    0x1(%ecx),%al
  69:	8a 5a 01             	mov    0x1(%edx),%bl
  6c:	84 c0                	test   %al,%al
  6e:	75 ec                	jne    5c <strcmp+0x1c>
  70:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
  72:	0f b6 db             	movzbl %bl,%ebx
  75:	29 d8                	sub    %ebx,%eax
}
  77:	5b                   	pop    %ebx
  78:	5e                   	pop    %esi
  79:	5d                   	pop    %ebp
  7a:	c3                   	ret    
  7b:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  7c:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
  7f:	0f b6 db             	movzbl %bl,%ebx
  82:	29 d8                	sub    %ebx,%eax
}
  84:	5b                   	pop    %ebx
  85:	5e                   	pop    %esi
  86:	5d                   	pop    %ebp
  87:	c3                   	ret    

00000088 <strlen>:

uint
strlen(const char *s)
{
  88:	55                   	push   %ebp
  89:	89 e5                	mov    %esp,%ebp
  8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  8e:	80 39 00             	cmpb   $0x0,(%ecx)
  91:	74 10                	je     a3 <strlen+0x1b>
  93:	31 d2                	xor    %edx,%edx
  95:	8d 76 00             	lea    0x0(%esi),%esi
  98:	42                   	inc    %edx
  99:	89 d0                	mov    %edx,%eax
  9b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  9f:	75 f7                	jne    98 <strlen+0x10>
    ;
  return n;
}
  a1:	5d                   	pop    %ebp
  a2:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
  a3:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
  a5:	5d                   	pop    %ebp
  a6:	c3                   	ret    
  a7:	90                   	nop

000000a8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  a8:	55                   	push   %ebp
  a9:	89 e5                	mov    %esp,%ebp
  ab:	57                   	push   %edi
  ac:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  af:	89 d7                	mov    %edx,%edi
  b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  b7:	fc                   	cld    
  b8:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  ba:	89 d0                	mov    %edx,%eax
  bc:	5f                   	pop    %edi
  bd:	5d                   	pop    %ebp
  be:	c3                   	ret    
  bf:	90                   	nop

000000c0 <strchr>:

char*
strchr(const char *s, char c)
{
  c0:	55                   	push   %ebp
  c1:	89 e5                	mov    %esp,%ebp
  c3:	8b 45 08             	mov    0x8(%ebp),%eax
  c6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
  c9:	8a 10                	mov    (%eax),%dl
  cb:	84 d2                	test   %dl,%dl
  cd:	75 0d                	jne    dc <strchr+0x1c>
  cf:	eb 13                	jmp    e4 <strchr+0x24>
  d1:	8d 76 00             	lea    0x0(%esi),%esi
  d4:	8a 50 01             	mov    0x1(%eax),%dl
  d7:	84 d2                	test   %dl,%dl
  d9:	74 09                	je     e4 <strchr+0x24>
  db:	40                   	inc    %eax
    if(*s == c)
  dc:	38 ca                	cmp    %cl,%dl
  de:	75 f4                	jne    d4 <strchr+0x14>
      return (char*)s;
  return 0;
}
  e0:	5d                   	pop    %ebp
  e1:	c3                   	ret    
  e2:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
  e4:	31 c0                	xor    %eax,%eax
}
  e6:	5d                   	pop    %ebp
  e7:	c3                   	ret    

000000e8 <gets>:

char*
gets(char *buf, int max)
{
  e8:	55                   	push   %ebp
  e9:	89 e5                	mov    %esp,%ebp
  eb:	57                   	push   %edi
  ec:	56                   	push   %esi
  ed:	53                   	push   %ebx
  ee:	83 ec 2c             	sub    $0x2c,%esp
  f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  f4:	31 f6                	xor    %esi,%esi
  f6:	eb 30                	jmp    128 <gets+0x40>
    cc = read(0, &c, 1);
  f8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  ff:	00 
 100:	8d 45 e7             	lea    -0x19(%ebp),%eax
 103:	89 44 24 04          	mov    %eax,0x4(%esp)
 107:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 10e:	e8 ed 00 00 00       	call   200 <read>
    if(cc < 1)
 113:	85 c0                	test   %eax,%eax
 115:	7e 19                	jle    130 <gets+0x48>
      break;
    buf[i++] = c;
 117:	8a 45 e7             	mov    -0x19(%ebp),%al
 11a:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 11e:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 120:	3c 0a                	cmp    $0xa,%al
 122:	74 0c                	je     130 <gets+0x48>
 124:	3c 0d                	cmp    $0xd,%al
 126:	74 08                	je     130 <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 128:	8d 5e 01             	lea    0x1(%esi),%ebx
 12b:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 12e:	7c c8                	jl     f8 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 130:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 134:	89 f8                	mov    %edi,%eax
 136:	83 c4 2c             	add    $0x2c,%esp
 139:	5b                   	pop    %ebx
 13a:	5e                   	pop    %esi
 13b:	5f                   	pop    %edi
 13c:	5d                   	pop    %ebp
 13d:	c3                   	ret    
 13e:	66 90                	xchg   %ax,%ax

00000140 <stat>:

int
stat(const char *n, struct stat *st)
{
 140:	55                   	push   %ebp
 141:	89 e5                	mov    %esp,%ebp
 143:	56                   	push   %esi
 144:	53                   	push   %ebx
 145:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 148:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 14f:	00 
 150:	8b 45 08             	mov    0x8(%ebp),%eax
 153:	89 04 24             	mov    %eax,(%esp)
 156:	e8 cd 00 00 00       	call   228 <open>
 15b:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 15d:	85 c0                	test   %eax,%eax
 15f:	78 23                	js     184 <stat+0x44>
    return -1;
  r = fstat(fd, st);
 161:	8b 45 0c             	mov    0xc(%ebp),%eax
 164:	89 44 24 04          	mov    %eax,0x4(%esp)
 168:	89 1c 24             	mov    %ebx,(%esp)
 16b:	e8 d0 00 00 00       	call   240 <fstat>
 170:	89 c6                	mov    %eax,%esi
  close(fd);
 172:	89 1c 24             	mov    %ebx,(%esp)
 175:	e8 96 00 00 00       	call   210 <close>
  return r;
}
 17a:	89 f0                	mov    %esi,%eax
 17c:	83 c4 10             	add    $0x10,%esp
 17f:	5b                   	pop    %ebx
 180:	5e                   	pop    %esi
 181:	5d                   	pop    %ebp
 182:	c3                   	ret    
 183:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 184:	be ff ff ff ff       	mov    $0xffffffff,%esi
 189:	eb ef                	jmp    17a <stat+0x3a>
 18b:	90                   	nop

0000018c <atoi>:
  return r;
}

int
atoi(const char *s)
{
 18c:	55                   	push   %ebp
 18d:	89 e5                	mov    %esp,%ebp
 18f:	53                   	push   %ebx
 190:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 193:	8a 11                	mov    (%ecx),%dl
 195:	8d 42 d0             	lea    -0x30(%edx),%eax
 198:	3c 09                	cmp    $0x9,%al
 19a:	b8 00 00 00 00       	mov    $0x0,%eax
 19f:	77 18                	ja     1b9 <atoi+0x2d>
 1a1:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 1a4:	8d 04 80             	lea    (%eax,%eax,4),%eax
 1a7:	0f be d2             	movsbl %dl,%edx
 1aa:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 1ae:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1af:	8a 11                	mov    (%ecx),%dl
 1b1:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1b4:	80 fb 09             	cmp    $0x9,%bl
 1b7:	76 eb                	jbe    1a4 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 1b9:	5b                   	pop    %ebx
 1ba:	5d                   	pop    %ebp
 1bb:	c3                   	ret    

000001bc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1bc:	55                   	push   %ebp
 1bd:	89 e5                	mov    %esp,%ebp
 1bf:	56                   	push   %esi
 1c0:	53                   	push   %ebx
 1c1:	8b 45 08             	mov    0x8(%ebp),%eax
 1c4:	8b 75 0c             	mov    0xc(%ebp),%esi
 1c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 1ca:	85 db                	test   %ebx,%ebx
 1cc:	7e 0d                	jle    1db <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 1ce:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 1d0:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 1d3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 1d6:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 1d7:	39 da                	cmp    %ebx,%edx
 1d9:	75 f5                	jne    1d0 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 1db:	5b                   	pop    %ebx
 1dc:	5e                   	pop    %esi
 1dd:	5d                   	pop    %ebp
 1de:	c3                   	ret    
 1df:	90                   	nop

000001e0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1e0:	b8 01 00 00 00       	mov    $0x1,%eax
 1e5:	cd 40                	int    $0x40
 1e7:	c3                   	ret    

000001e8 <exit>:
SYSCALL(exit)
 1e8:	b8 02 00 00 00       	mov    $0x2,%eax
 1ed:	cd 40                	int    $0x40
 1ef:	c3                   	ret    

000001f0 <wait>:
SYSCALL(wait)
 1f0:	b8 03 00 00 00       	mov    $0x3,%eax
 1f5:	cd 40                	int    $0x40
 1f7:	c3                   	ret    

000001f8 <pipe>:
SYSCALL(pipe)
 1f8:	b8 04 00 00 00       	mov    $0x4,%eax
 1fd:	cd 40                	int    $0x40
 1ff:	c3                   	ret    

00000200 <read>:
SYSCALL(read)
 200:	b8 05 00 00 00       	mov    $0x5,%eax
 205:	cd 40                	int    $0x40
 207:	c3                   	ret    

00000208 <write>:
SYSCALL(write)
 208:	b8 10 00 00 00       	mov    $0x10,%eax
 20d:	cd 40                	int    $0x40
 20f:	c3                   	ret    

00000210 <close>:
SYSCALL(close)
 210:	b8 15 00 00 00       	mov    $0x15,%eax
 215:	cd 40                	int    $0x40
 217:	c3                   	ret    

00000218 <kill>:
SYSCALL(kill)
 218:	b8 06 00 00 00       	mov    $0x6,%eax
 21d:	cd 40                	int    $0x40
 21f:	c3                   	ret    

00000220 <exec>:
SYSCALL(exec)
 220:	b8 07 00 00 00       	mov    $0x7,%eax
 225:	cd 40                	int    $0x40
 227:	c3                   	ret    

00000228 <open>:
SYSCALL(open)
 228:	b8 0f 00 00 00       	mov    $0xf,%eax
 22d:	cd 40                	int    $0x40
 22f:	c3                   	ret    

00000230 <mknod>:
SYSCALL(mknod)
 230:	b8 11 00 00 00       	mov    $0x11,%eax
 235:	cd 40                	int    $0x40
 237:	c3                   	ret    

00000238 <unlink>:
SYSCALL(unlink)
 238:	b8 12 00 00 00       	mov    $0x12,%eax
 23d:	cd 40                	int    $0x40
 23f:	c3                   	ret    

00000240 <fstat>:
SYSCALL(fstat)
 240:	b8 08 00 00 00       	mov    $0x8,%eax
 245:	cd 40                	int    $0x40
 247:	c3                   	ret    

00000248 <link>:
SYSCALL(link)
 248:	b8 13 00 00 00       	mov    $0x13,%eax
 24d:	cd 40                	int    $0x40
 24f:	c3                   	ret    

00000250 <mkdir>:
SYSCALL(mkdir)
 250:	b8 14 00 00 00       	mov    $0x14,%eax
 255:	cd 40                	int    $0x40
 257:	c3                   	ret    

00000258 <chdir>:
SYSCALL(chdir)
 258:	b8 09 00 00 00       	mov    $0x9,%eax
 25d:	cd 40                	int    $0x40
 25f:	c3                   	ret    

00000260 <dup>:
SYSCALL(dup)
 260:	b8 0a 00 00 00       	mov    $0xa,%eax
 265:	cd 40                	int    $0x40
 267:	c3                   	ret    

00000268 <getpid>:
SYSCALL(getpid)
 268:	b8 0b 00 00 00       	mov    $0xb,%eax
 26d:	cd 40                	int    $0x40
 26f:	c3                   	ret    

00000270 <sbrk>:
SYSCALL(sbrk)
 270:	b8 0c 00 00 00       	mov    $0xc,%eax
 275:	cd 40                	int    $0x40
 277:	c3                   	ret    

00000278 <sleep>:
SYSCALL(sleep)
 278:	b8 0d 00 00 00       	mov    $0xd,%eax
 27d:	cd 40                	int    $0x40
 27f:	c3                   	ret    

00000280 <uptime>:
SYSCALL(uptime)
 280:	b8 0e 00 00 00       	mov    $0xe,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <alarm>:
SYSCALL(alarm)
 288:	b8 16 00 00 00       	mov    $0x16,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 290:	55                   	push   %ebp
 291:	89 e5                	mov    %esp,%ebp
 293:	83 ec 28             	sub    $0x28,%esp
 296:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 299:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2a0:	00 
 2a1:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2a4:	89 54 24 04          	mov    %edx,0x4(%esp)
 2a8:	89 04 24             	mov    %eax,(%esp)
 2ab:	e8 58 ff ff ff       	call   208 <write>
}
 2b0:	c9                   	leave  
 2b1:	c3                   	ret    
 2b2:	66 90                	xchg   %ax,%ax

000002b4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2b4:	55                   	push   %ebp
 2b5:	89 e5                	mov    %esp,%ebp
 2b7:	57                   	push   %edi
 2b8:	56                   	push   %esi
 2b9:	53                   	push   %ebx
 2ba:	83 ec 1c             	sub    $0x1c,%esp
 2bd:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 2bf:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
 2c4:	85 db                	test   %ebx,%ebx
 2c6:	74 04                	je     2cc <printint+0x18>
 2c8:	85 d2                	test   %edx,%edx
 2ca:	78 4a                	js     316 <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 2cc:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 2ce:	31 db                	xor    %ebx,%ebx
 2d0:	eb 04                	jmp    2d6 <printint+0x22>
 2d2:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 2d4:	89 d3                	mov    %edx,%ebx
 2d6:	31 d2                	xor    %edx,%edx
 2d8:	f7 f1                	div    %ecx
 2da:	8a 92 b9 05 00 00    	mov    0x5b9(%edx),%dl
 2e0:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 2e4:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 2e7:	85 c0                	test   %eax,%eax
 2e9:	75 e9                	jne    2d4 <printint+0x20>
  if(neg)
 2eb:	85 ff                	test   %edi,%edi
 2ed:	74 08                	je     2f7 <printint+0x43>
    buf[i++] = '-';
 2ef:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 2f4:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 2f7:	8d 5a ff             	lea    -0x1(%edx),%ebx
 2fa:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 2fc:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 301:	89 f0                	mov    %esi,%eax
 303:	e8 88 ff ff ff       	call   290 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 308:	4b                   	dec    %ebx
 309:	83 fb ff             	cmp    $0xffffffff,%ebx
 30c:	75 ee                	jne    2fc <printint+0x48>
    putc(fd, buf[i]);
}
 30e:	83 c4 1c             	add    $0x1c,%esp
 311:	5b                   	pop    %ebx
 312:	5e                   	pop    %esi
 313:	5f                   	pop    %edi
 314:	5d                   	pop    %ebp
 315:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 316:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 318:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 31d:	eb af                	jmp    2ce <printint+0x1a>
 31f:	90                   	nop

00000320 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 320:	55                   	push   %ebp
 321:	89 e5                	mov    %esp,%ebp
 323:	57                   	push   %edi
 324:	56                   	push   %esi
 325:	53                   	push   %ebx
 326:	83 ec 2c             	sub    $0x2c,%esp
 329:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 32c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 32f:	8a 0b                	mov    (%ebx),%cl
 331:	84 c9                	test   %cl,%cl
 333:	74 7b                	je     3b0 <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 335:	8d 45 10             	lea    0x10(%ebp),%eax
 338:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 33b:	31 f6                	xor    %esi,%esi
 33d:	eb 17                	jmp    356 <printf+0x36>
 33f:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 340:	83 f9 25             	cmp    $0x25,%ecx
 343:	74 73                	je     3b8 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 345:	0f be d1             	movsbl %cl,%edx
 348:	89 f8                	mov    %edi,%eax
 34a:	e8 41 ff ff ff       	call   290 <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 34f:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 350:	8a 0b                	mov    (%ebx),%cl
 352:	84 c9                	test   %cl,%cl
 354:	74 5a                	je     3b0 <printf+0x90>
    c = fmt[i] & 0xff;
 356:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 359:	85 f6                	test   %esi,%esi
 35b:	74 e3                	je     340 <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 35d:	83 fe 25             	cmp    $0x25,%esi
 360:	75 ed                	jne    34f <printf+0x2f>
      if(c == 'd'){
 362:	83 f9 64             	cmp    $0x64,%ecx
 365:	0f 84 c1 00 00 00    	je     42c <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 36b:	83 f9 78             	cmp    $0x78,%ecx
 36e:	74 50                	je     3c0 <printf+0xa0>
 370:	83 f9 70             	cmp    $0x70,%ecx
 373:	74 4b                	je     3c0 <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 375:	83 f9 73             	cmp    $0x73,%ecx
 378:	74 6a                	je     3e4 <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 37a:	83 f9 63             	cmp    $0x63,%ecx
 37d:	0f 84 91 00 00 00    	je     414 <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 383:	ba 25 00 00 00       	mov    $0x25,%edx
 388:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 38a:	83 f9 25             	cmp    $0x25,%ecx
 38d:	74 10                	je     39f <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 38f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 392:	e8 f9 fe ff ff       	call   290 <putc>
        putc(fd, c);
 397:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 39a:	0f be d1             	movsbl %cl,%edx
 39d:	89 f8                	mov    %edi,%eax
 39f:	e8 ec fe ff ff       	call   290 <putc>
      }
      state = 0;
 3a4:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 3a6:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3a7:	8a 0b                	mov    (%ebx),%cl
 3a9:	84 c9                	test   %cl,%cl
 3ab:	75 a9                	jne    356 <printf+0x36>
 3ad:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 3b0:	83 c4 2c             	add    $0x2c,%esp
 3b3:	5b                   	pop    %ebx
 3b4:	5e                   	pop    %esi
 3b5:	5f                   	pop    %edi
 3b6:	5d                   	pop    %ebp
 3b7:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 3b8:	be 25 00 00 00       	mov    $0x25,%esi
 3bd:	eb 90                	jmp    34f <printf+0x2f>
 3bf:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 3c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 3c7:	b9 10 00 00 00       	mov    $0x10,%ecx
 3cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3cf:	8b 10                	mov    (%eax),%edx
 3d1:	89 f8                	mov    %edi,%eax
 3d3:	e8 dc fe ff ff       	call   2b4 <printint>
        ap++;
 3d8:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 3dc:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 3de:	e9 6c ff ff ff       	jmp    34f <printf+0x2f>
 3e3:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 3e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3e7:	8b 30                	mov    (%eax),%esi
        ap++;
 3e9:	83 c0 04             	add    $0x4,%eax
 3ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 3ef:	85 f6                	test   %esi,%esi
 3f1:	74 5a                	je     44d <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 3f3:	8a 16                	mov    (%esi),%dl
 3f5:	84 d2                	test   %dl,%dl
 3f7:	74 14                	je     40d <printf+0xed>
 3f9:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 3fc:	0f be d2             	movsbl %dl,%edx
 3ff:	89 f8                	mov    %edi,%eax
 401:	e8 8a fe ff ff       	call   290 <putc>
          s++;
 406:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 407:	8a 16                	mov    (%esi),%dl
 409:	84 d2                	test   %dl,%dl
 40b:	75 ef                	jne    3fc <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 40d:	31 f6                	xor    %esi,%esi
 40f:	e9 3b ff ff ff       	jmp    34f <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 414:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 417:	0f be 10             	movsbl (%eax),%edx
 41a:	89 f8                	mov    %edi,%eax
 41c:	e8 6f fe ff ff       	call   290 <putc>
        ap++;
 421:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 425:	31 f6                	xor    %esi,%esi
 427:	e9 23 ff ff ff       	jmp    34f <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 42c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 433:	b1 0a                	mov    $0xa,%cl
 435:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 438:	8b 10                	mov    (%eax),%edx
 43a:	89 f8                	mov    %edi,%eax
 43c:	e8 73 fe ff ff       	call   2b4 <printint>
        ap++;
 441:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 445:	66 31 f6             	xor    %si,%si
 448:	e9 02 ff ff ff       	jmp    34f <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 44d:	be b2 05 00 00       	mov    $0x5b2,%esi
 452:	eb 9f                	jmp    3f3 <printf+0xd3>

00000454 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 454:	55                   	push   %ebp
 455:	89 e5                	mov    %esp,%ebp
 457:	57                   	push   %edi
 458:	56                   	push   %esi
 459:	53                   	push   %ebx
 45a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 45d:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 460:	a1 6c 08 00 00       	mov    0x86c,%eax
 465:	8d 76 00             	lea    0x0(%esi),%esi
 468:	8b 10                	mov    (%eax),%edx
 46a:	39 c8                	cmp    %ecx,%eax
 46c:	73 04                	jae    472 <free+0x1e>
 46e:	39 d1                	cmp    %edx,%ecx
 470:	72 12                	jb     484 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 472:	39 d0                	cmp    %edx,%eax
 474:	72 08                	jb     47e <free+0x2a>
 476:	39 c8                	cmp    %ecx,%eax
 478:	72 0a                	jb     484 <free+0x30>
 47a:	39 d1                	cmp    %edx,%ecx
 47c:	72 06                	jb     484 <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 47e:	89 d0                	mov    %edx,%eax
 480:	eb e6                	jmp    468 <free+0x14>
 482:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 484:	8b 73 fc             	mov    -0x4(%ebx),%esi
 487:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 48a:	39 d7                	cmp    %edx,%edi
 48c:	74 19                	je     4a7 <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 48e:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 491:	8b 50 04             	mov    0x4(%eax),%edx
 494:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 497:	39 f1                	cmp    %esi,%ecx
 499:	74 23                	je     4be <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 49b:	89 08                	mov    %ecx,(%eax)
  freep = p;
 49d:	a3 6c 08 00 00       	mov    %eax,0x86c
}
 4a2:	5b                   	pop    %ebx
 4a3:	5e                   	pop    %esi
 4a4:	5f                   	pop    %edi
 4a5:	5d                   	pop    %ebp
 4a6:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 4a7:	03 72 04             	add    0x4(%edx),%esi
 4aa:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4ad:	8b 10                	mov    (%eax),%edx
 4af:	8b 12                	mov    (%edx),%edx
 4b1:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 4b4:	8b 50 04             	mov    0x4(%eax),%edx
 4b7:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4ba:	39 f1                	cmp    %esi,%ecx
 4bc:	75 dd                	jne    49b <free+0x47>
    p->s.size += bp->s.size;
 4be:	03 53 fc             	add    -0x4(%ebx),%edx
 4c1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4c4:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4c7:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 4c9:	a3 6c 08 00 00       	mov    %eax,0x86c
}
 4ce:	5b                   	pop    %ebx
 4cf:	5e                   	pop    %esi
 4d0:	5f                   	pop    %edi
 4d1:	5d                   	pop    %ebp
 4d2:	c3                   	ret    
 4d3:	90                   	nop

000004d4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 4d4:	55                   	push   %ebp
 4d5:	89 e5                	mov    %esp,%ebp
 4d7:	57                   	push   %edi
 4d8:	56                   	push   %esi
 4d9:	53                   	push   %ebx
 4da:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 4dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
 4e0:	83 c3 07             	add    $0x7,%ebx
 4e3:	c1 eb 03             	shr    $0x3,%ebx
 4e6:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 4e7:	8b 0d 6c 08 00 00    	mov    0x86c,%ecx
 4ed:	85 c9                	test   %ecx,%ecx
 4ef:	0f 84 95 00 00 00    	je     58a <malloc+0xb6>
 4f5:	8b 01                	mov    (%ecx),%eax
 4f7:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 4fa:	39 da                	cmp    %ebx,%edx
 4fc:	73 66                	jae    564 <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 4fe:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 505:	eb 0c                	jmp    513 <malloc+0x3f>
 507:	90                   	nop
    }
    if(p == freep)
 508:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 50a:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 50c:	8b 50 04             	mov    0x4(%eax),%edx
 50f:	39 d3                	cmp    %edx,%ebx
 511:	76 51                	jbe    564 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 513:	3b 05 6c 08 00 00    	cmp    0x86c,%eax
 519:	75 ed                	jne    508 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 51b:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 521:	76 35                	jbe    558 <malloc+0x84>
 523:	89 f8                	mov    %edi,%eax
 525:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 527:	89 04 24             	mov    %eax,(%esp)
 52a:	e8 41 fd ff ff       	call   270 <sbrk>
  if(p == (char*)-1)
 52f:	83 f8 ff             	cmp    $0xffffffff,%eax
 532:	74 18                	je     54c <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 534:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 537:	83 c0 08             	add    $0x8,%eax
 53a:	89 04 24             	mov    %eax,(%esp)
 53d:	e8 12 ff ff ff       	call   454 <free>
  return freep;
 542:	8b 0d 6c 08 00 00    	mov    0x86c,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 548:	85 c9                	test   %ecx,%ecx
 54a:	75 be                	jne    50a <malloc+0x36>
        return 0;
 54c:	31 c0                	xor    %eax,%eax
  }
}
 54e:	83 c4 1c             	add    $0x1c,%esp
 551:	5b                   	pop    %ebx
 552:	5e                   	pop    %esi
 553:	5f                   	pop    %edi
 554:	5d                   	pop    %ebp
 555:	c3                   	ret    
 556:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 558:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 55d:	be 00 10 00 00       	mov    $0x1000,%esi
 562:	eb c3                	jmp    527 <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 564:	39 d3                	cmp    %edx,%ebx
 566:	74 1c                	je     584 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 568:	29 da                	sub    %ebx,%edx
 56a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 56d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 570:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 573:	89 0d 6c 08 00 00    	mov    %ecx,0x86c
      return (void*)(p + 1);
 579:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 57c:	83 c4 1c             	add    $0x1c,%esp
 57f:	5b                   	pop    %ebx
 580:	5e                   	pop    %esi
 581:	5f                   	pop    %edi
 582:	5d                   	pop    %ebp
 583:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 584:	8b 10                	mov    (%eax),%edx
 586:	89 11                	mov    %edx,(%ecx)
 588:	eb e9                	jmp    573 <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 58a:	c7 05 6c 08 00 00 70 	movl   $0x870,0x86c
 591:	08 00 00 
 594:	c7 05 70 08 00 00 70 	movl   $0x870,0x870
 59b:	08 00 00 
    base.s.size = 0;
 59e:	c7 05 74 08 00 00 00 	movl   $0x0,0x874
 5a5:	00 00 00 
 5a8:	b8 70 08 00 00       	mov    $0x870,%eax
 5ad:	e9 4c ff ff ff       	jmp    4fe <malloc+0x2a>

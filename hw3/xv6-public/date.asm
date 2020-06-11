
_date:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "date.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 40             	sub    $0x40,%esp
  struct rtcdate r;

  if (date(&r)) {
   9:	8d 44 24 28          	lea    0x28(%esp),%eax
   d:	89 04 24             	mov    %eax,(%esp)
  10:	e8 cb 02 00 00       	call   2e0 <date>
  15:	85 c0                	test   %eax,%eax
  17:	74 19                	je     32 <main+0x32>
    printf(2, "date failed\n");
  19:	c7 44 24 04 0c 06 00 	movl   $0x60c,0x4(%esp)
  20:	00 
  21:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  28:	e8 4b 03 00 00       	call   378 <printf>
    exit();
  2d:	e8 0e 02 00 00       	call   240 <exit>
  }

  // your code to print the time in any format you like...
  printf(2, "The time now is: %d/%d/%d %d:%d:%d\n", r.month, r.day, r.year, r.hour, r.minute, r.second);
  32:	8b 44 24 28          	mov    0x28(%esp),%eax
  36:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  3a:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  3e:	89 44 24 18          	mov    %eax,0x18(%esp)
  42:	8b 44 24 30          	mov    0x30(%esp),%eax
  46:	89 44 24 14          	mov    %eax,0x14(%esp)
  4a:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  52:	8b 44 24 34          	mov    0x34(%esp),%eax
  56:	89 44 24 0c          	mov    %eax,0xc(%esp)
  5a:	8b 44 24 38          	mov    0x38(%esp),%eax
  5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  62:	c7 44 24 04 1c 06 00 	movl   $0x61c,0x4(%esp)
  69:	00 
  6a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  71:	e8 02 03 00 00       	call   378 <printf>
  exit();
  76:	e8 c5 01 00 00       	call   240 <exit>
  7b:	90                   	nop

0000007c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  7c:	55                   	push   %ebp
  7d:	89 e5                	mov    %esp,%ebp
  7f:	53                   	push   %ebx
  80:	8b 45 08             	mov    0x8(%ebp),%eax
  83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  86:	31 d2                	xor    %edx,%edx
  88:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8b:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8e:	42                   	inc    %edx
  8f:	84 c9                	test   %cl,%cl
  91:	75 f5                	jne    88 <strcpy+0xc>
    ;
  return os;
}
  93:	5b                   	pop    %ebx
  94:	5d                   	pop    %ebp
  95:	c3                   	ret    
  96:	66 90                	xchg   %ax,%ax

00000098 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  98:	55                   	push   %ebp
  99:	89 e5                	mov    %esp,%ebp
  9b:	56                   	push   %esi
  9c:	53                   	push   %ebx
  9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  a3:	8a 01                	mov    (%ecx),%al
  a5:	8a 1a                	mov    (%edx),%bl
  a7:	84 c0                	test   %al,%al
  a9:	74 1d                	je     c8 <strcmp+0x30>
  ab:	38 d8                	cmp    %bl,%al
  ad:	74 0c                	je     bb <strcmp+0x23>
  af:	eb 23                	jmp    d4 <strcmp+0x3c>
  b1:	8d 76 00             	lea    0x0(%esi),%esi
  b4:	41                   	inc    %ecx
  b5:	38 d8                	cmp    %bl,%al
  b7:	75 1b                	jne    d4 <strcmp+0x3c>
    p++, q++;
  b9:	89 f2                	mov    %esi,%edx
  bb:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  be:	8a 41 01             	mov    0x1(%ecx),%al
  c1:	8a 5a 01             	mov    0x1(%edx),%bl
  c4:	84 c0                	test   %al,%al
  c6:	75 ec                	jne    b4 <strcmp+0x1c>
  c8:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
  ca:	0f b6 db             	movzbl %bl,%ebx
  cd:	29 d8                	sub    %ebx,%eax
}
  cf:	5b                   	pop    %ebx
  d0:	5e                   	pop    %esi
  d1:	5d                   	pop    %ebp
  d2:	c3                   	ret    
  d3:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  d4:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
  d7:	0f b6 db             	movzbl %bl,%ebx
  da:	29 d8                	sub    %ebx,%eax
}
  dc:	5b                   	pop    %ebx
  dd:	5e                   	pop    %esi
  de:	5d                   	pop    %ebp
  df:	c3                   	ret    

000000e0 <strlen>:

uint
strlen(const char *s)
{
  e0:	55                   	push   %ebp
  e1:	89 e5                	mov    %esp,%ebp
  e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  e6:	80 39 00             	cmpb   $0x0,(%ecx)
  e9:	74 10                	je     fb <strlen+0x1b>
  eb:	31 d2                	xor    %edx,%edx
  ed:	8d 76 00             	lea    0x0(%esi),%esi
  f0:	42                   	inc    %edx
  f1:	89 d0                	mov    %edx,%eax
  f3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  f7:	75 f7                	jne    f0 <strlen+0x10>
    ;
  return n;
}
  f9:	5d                   	pop    %ebp
  fa:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
  fb:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
  fd:	5d                   	pop    %ebp
  fe:	c3                   	ret    
  ff:	90                   	nop

00000100 <memset>:

void*
memset(void *dst, int c, uint n)
{
 100:	55                   	push   %ebp
 101:	89 e5                	mov    %esp,%ebp
 103:	57                   	push   %edi
 104:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 107:	89 d7                	mov    %edx,%edi
 109:	8b 4d 10             	mov    0x10(%ebp),%ecx
 10c:	8b 45 0c             	mov    0xc(%ebp),%eax
 10f:	fc                   	cld    
 110:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 112:	89 d0                	mov    %edx,%eax
 114:	5f                   	pop    %edi
 115:	5d                   	pop    %ebp
 116:	c3                   	ret    
 117:	90                   	nop

00000118 <strchr>:

char*
strchr(const char *s, char c)
{
 118:	55                   	push   %ebp
 119:	89 e5                	mov    %esp,%ebp
 11b:	8b 45 08             	mov    0x8(%ebp),%eax
 11e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 121:	8a 10                	mov    (%eax),%dl
 123:	84 d2                	test   %dl,%dl
 125:	75 0d                	jne    134 <strchr+0x1c>
 127:	eb 13                	jmp    13c <strchr+0x24>
 129:	8d 76 00             	lea    0x0(%esi),%esi
 12c:	8a 50 01             	mov    0x1(%eax),%dl
 12f:	84 d2                	test   %dl,%dl
 131:	74 09                	je     13c <strchr+0x24>
 133:	40                   	inc    %eax
    if(*s == c)
 134:	38 ca                	cmp    %cl,%dl
 136:	75 f4                	jne    12c <strchr+0x14>
      return (char*)s;
  return 0;
}
 138:	5d                   	pop    %ebp
 139:	c3                   	ret    
 13a:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
 13c:	31 c0                	xor    %eax,%eax
}
 13e:	5d                   	pop    %ebp
 13f:	c3                   	ret    

00000140 <gets>:

char*
gets(char *buf, int max)
{
 140:	55                   	push   %ebp
 141:	89 e5                	mov    %esp,%ebp
 143:	57                   	push   %edi
 144:	56                   	push   %esi
 145:	53                   	push   %ebx
 146:	83 ec 2c             	sub    $0x2c,%esp
 149:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 14c:	31 f6                	xor    %esi,%esi
 14e:	eb 30                	jmp    180 <gets+0x40>
    cc = read(0, &c, 1);
 150:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 157:	00 
 158:	8d 45 e7             	lea    -0x19(%ebp),%eax
 15b:	89 44 24 04          	mov    %eax,0x4(%esp)
 15f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 166:	e8 ed 00 00 00       	call   258 <read>
    if(cc < 1)
 16b:	85 c0                	test   %eax,%eax
 16d:	7e 19                	jle    188 <gets+0x48>
      break;
    buf[i++] = c;
 16f:	8a 45 e7             	mov    -0x19(%ebp),%al
 172:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 176:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 178:	3c 0a                	cmp    $0xa,%al
 17a:	74 0c                	je     188 <gets+0x48>
 17c:	3c 0d                	cmp    $0xd,%al
 17e:	74 08                	je     188 <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 180:	8d 5e 01             	lea    0x1(%esi),%ebx
 183:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 186:	7c c8                	jl     150 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 188:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 18c:	89 f8                	mov    %edi,%eax
 18e:	83 c4 2c             	add    $0x2c,%esp
 191:	5b                   	pop    %ebx
 192:	5e                   	pop    %esi
 193:	5f                   	pop    %edi
 194:	5d                   	pop    %ebp
 195:	c3                   	ret    
 196:	66 90                	xchg   %ax,%ax

00000198 <stat>:

int
stat(const char *n, struct stat *st)
{
 198:	55                   	push   %ebp
 199:	89 e5                	mov    %esp,%ebp
 19b:	56                   	push   %esi
 19c:	53                   	push   %ebx
 19d:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1a7:	00 
 1a8:	8b 45 08             	mov    0x8(%ebp),%eax
 1ab:	89 04 24             	mov    %eax,(%esp)
 1ae:	e8 cd 00 00 00       	call   280 <open>
 1b3:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 1b5:	85 c0                	test   %eax,%eax
 1b7:	78 23                	js     1dc <stat+0x44>
    return -1;
  r = fstat(fd, st);
 1b9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c0:	89 1c 24             	mov    %ebx,(%esp)
 1c3:	e8 d0 00 00 00       	call   298 <fstat>
 1c8:	89 c6                	mov    %eax,%esi
  close(fd);
 1ca:	89 1c 24             	mov    %ebx,(%esp)
 1cd:	e8 96 00 00 00       	call   268 <close>
  return r;
}
 1d2:	89 f0                	mov    %esi,%eax
 1d4:	83 c4 10             	add    $0x10,%esp
 1d7:	5b                   	pop    %ebx
 1d8:	5e                   	pop    %esi
 1d9:	5d                   	pop    %ebp
 1da:	c3                   	ret    
 1db:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 1dc:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1e1:	eb ef                	jmp    1d2 <stat+0x3a>
 1e3:	90                   	nop

000001e4 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 1e4:	55                   	push   %ebp
 1e5:	89 e5                	mov    %esp,%ebp
 1e7:	53                   	push   %ebx
 1e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1eb:	8a 11                	mov    (%ecx),%dl
 1ed:	8d 42 d0             	lea    -0x30(%edx),%eax
 1f0:	3c 09                	cmp    $0x9,%al
 1f2:	b8 00 00 00 00       	mov    $0x0,%eax
 1f7:	77 18                	ja     211 <atoi+0x2d>
 1f9:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 1fc:	8d 04 80             	lea    (%eax,%eax,4),%eax
 1ff:	0f be d2             	movsbl %dl,%edx
 202:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 206:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 207:	8a 11                	mov    (%ecx),%dl
 209:	8d 5a d0             	lea    -0x30(%edx),%ebx
 20c:	80 fb 09             	cmp    $0x9,%bl
 20f:	76 eb                	jbe    1fc <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 211:	5b                   	pop    %ebx
 212:	5d                   	pop    %ebp
 213:	c3                   	ret    

00000214 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 214:	55                   	push   %ebp
 215:	89 e5                	mov    %esp,%ebp
 217:	56                   	push   %esi
 218:	53                   	push   %ebx
 219:	8b 45 08             	mov    0x8(%ebp),%eax
 21c:	8b 75 0c             	mov    0xc(%ebp),%esi
 21f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 222:	85 db                	test   %ebx,%ebx
 224:	7e 0d                	jle    233 <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 226:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 228:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 22b:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 22e:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 22f:	39 da                	cmp    %ebx,%edx
 231:	75 f5                	jne    228 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 233:	5b                   	pop    %ebx
 234:	5e                   	pop    %esi
 235:	5d                   	pop    %ebp
 236:	c3                   	ret    
 237:	90                   	nop

00000238 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 238:	b8 01 00 00 00       	mov    $0x1,%eax
 23d:	cd 40                	int    $0x40
 23f:	c3                   	ret    

00000240 <exit>:
SYSCALL(exit)
 240:	b8 02 00 00 00       	mov    $0x2,%eax
 245:	cd 40                	int    $0x40
 247:	c3                   	ret    

00000248 <wait>:
SYSCALL(wait)
 248:	b8 03 00 00 00       	mov    $0x3,%eax
 24d:	cd 40                	int    $0x40
 24f:	c3                   	ret    

00000250 <pipe>:
SYSCALL(pipe)
 250:	b8 04 00 00 00       	mov    $0x4,%eax
 255:	cd 40                	int    $0x40
 257:	c3                   	ret    

00000258 <read>:
SYSCALL(read)
 258:	b8 05 00 00 00       	mov    $0x5,%eax
 25d:	cd 40                	int    $0x40
 25f:	c3                   	ret    

00000260 <write>:
SYSCALL(write)
 260:	b8 10 00 00 00       	mov    $0x10,%eax
 265:	cd 40                	int    $0x40
 267:	c3                   	ret    

00000268 <close>:
SYSCALL(close)
 268:	b8 15 00 00 00       	mov    $0x15,%eax
 26d:	cd 40                	int    $0x40
 26f:	c3                   	ret    

00000270 <kill>:
SYSCALL(kill)
 270:	b8 06 00 00 00       	mov    $0x6,%eax
 275:	cd 40                	int    $0x40
 277:	c3                   	ret    

00000278 <exec>:
SYSCALL(exec)
 278:	b8 07 00 00 00       	mov    $0x7,%eax
 27d:	cd 40                	int    $0x40
 27f:	c3                   	ret    

00000280 <open>:
SYSCALL(open)
 280:	b8 0f 00 00 00       	mov    $0xf,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <mknod>:
SYSCALL(mknod)
 288:	b8 11 00 00 00       	mov    $0x11,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <unlink>:
SYSCALL(unlink)
 290:	b8 12 00 00 00       	mov    $0x12,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <fstat>:
SYSCALL(fstat)
 298:	b8 08 00 00 00       	mov    $0x8,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <link>:
SYSCALL(link)
 2a0:	b8 13 00 00 00       	mov    $0x13,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <mkdir>:
SYSCALL(mkdir)
 2a8:	b8 14 00 00 00       	mov    $0x14,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <chdir>:
SYSCALL(chdir)
 2b0:	b8 09 00 00 00       	mov    $0x9,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <dup>:
SYSCALL(dup)
 2b8:	b8 0a 00 00 00       	mov    $0xa,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <getpid>:
SYSCALL(getpid)
 2c0:	b8 0b 00 00 00       	mov    $0xb,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <sbrk>:
SYSCALL(sbrk)
 2c8:	b8 0c 00 00 00       	mov    $0xc,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <sleep>:
SYSCALL(sleep)
 2d0:	b8 0d 00 00 00       	mov    $0xd,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <uptime>:
SYSCALL(uptime)
 2d8:	b8 0e 00 00 00       	mov    $0xe,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <date>:
SYSCALL(date)
 2e0:	b8 16 00 00 00       	mov    $0x16,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2e8:	55                   	push   %ebp
 2e9:	89 e5                	mov    %esp,%ebp
 2eb:	83 ec 28             	sub    $0x28,%esp
 2ee:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2f1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2f8:	00 
 2f9:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2fc:	89 54 24 04          	mov    %edx,0x4(%esp)
 300:	89 04 24             	mov    %eax,(%esp)
 303:	e8 58 ff ff ff       	call   260 <write>
}
 308:	c9                   	leave  
 309:	c3                   	ret    
 30a:	66 90                	xchg   %ax,%ax

0000030c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 30c:	55                   	push   %ebp
 30d:	89 e5                	mov    %esp,%ebp
 30f:	57                   	push   %edi
 310:	56                   	push   %esi
 311:	53                   	push   %ebx
 312:	83 ec 1c             	sub    $0x1c,%esp
 315:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 317:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 319:	8b 5d 08             	mov    0x8(%ebp),%ebx
 31c:	85 db                	test   %ebx,%ebx
 31e:	74 04                	je     324 <printint+0x18>
 320:	85 d2                	test   %edx,%edx
 322:	78 4a                	js     36e <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 324:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 326:	31 db                	xor    %ebx,%ebx
 328:	eb 04                	jmp    32e <printint+0x22>
 32a:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 32c:	89 d3                	mov    %edx,%ebx
 32e:	31 d2                	xor    %edx,%edx
 330:	f7 f1                	div    %ecx
 332:	8a 92 47 06 00 00    	mov    0x647(%edx),%dl
 338:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 33c:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 33f:	85 c0                	test   %eax,%eax
 341:	75 e9                	jne    32c <printint+0x20>
  if(neg)
 343:	85 ff                	test   %edi,%edi
 345:	74 08                	je     34f <printint+0x43>
    buf[i++] = '-';
 347:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 34c:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 34f:	8d 5a ff             	lea    -0x1(%edx),%ebx
 352:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 354:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 359:	89 f0                	mov    %esi,%eax
 35b:	e8 88 ff ff ff       	call   2e8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 360:	4b                   	dec    %ebx
 361:	83 fb ff             	cmp    $0xffffffff,%ebx
 364:	75 ee                	jne    354 <printint+0x48>
    putc(fd, buf[i]);
}
 366:	83 c4 1c             	add    $0x1c,%esp
 369:	5b                   	pop    %ebx
 36a:	5e                   	pop    %esi
 36b:	5f                   	pop    %edi
 36c:	5d                   	pop    %ebp
 36d:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 36e:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 370:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 375:	eb af                	jmp    326 <printint+0x1a>
 377:	90                   	nop

00000378 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 378:	55                   	push   %ebp
 379:	89 e5                	mov    %esp,%ebp
 37b:	57                   	push   %edi
 37c:	56                   	push   %esi
 37d:	53                   	push   %ebx
 37e:	83 ec 2c             	sub    $0x2c,%esp
 381:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 384:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 387:	8a 0b                	mov    (%ebx),%cl
 389:	84 c9                	test   %cl,%cl
 38b:	74 7b                	je     408 <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 38d:	8d 45 10             	lea    0x10(%ebp),%eax
 390:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 393:	31 f6                	xor    %esi,%esi
 395:	eb 17                	jmp    3ae <printf+0x36>
 397:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 398:	83 f9 25             	cmp    $0x25,%ecx
 39b:	74 73                	je     410 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 39d:	0f be d1             	movsbl %cl,%edx
 3a0:	89 f8                	mov    %edi,%eax
 3a2:	e8 41 ff ff ff       	call   2e8 <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 3a7:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3a8:	8a 0b                	mov    (%ebx),%cl
 3aa:	84 c9                	test   %cl,%cl
 3ac:	74 5a                	je     408 <printf+0x90>
    c = fmt[i] & 0xff;
 3ae:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 3b1:	85 f6                	test   %esi,%esi
 3b3:	74 e3                	je     398 <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 3b5:	83 fe 25             	cmp    $0x25,%esi
 3b8:	75 ed                	jne    3a7 <printf+0x2f>
      if(c == 'd'){
 3ba:	83 f9 64             	cmp    $0x64,%ecx
 3bd:	0f 84 c1 00 00 00    	je     484 <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3c3:	83 f9 78             	cmp    $0x78,%ecx
 3c6:	74 50                	je     418 <printf+0xa0>
 3c8:	83 f9 70             	cmp    $0x70,%ecx
 3cb:	74 4b                	je     418 <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3cd:	83 f9 73             	cmp    $0x73,%ecx
 3d0:	74 6a                	je     43c <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3d2:	83 f9 63             	cmp    $0x63,%ecx
 3d5:	0f 84 91 00 00 00    	je     46c <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 3db:	ba 25 00 00 00       	mov    $0x25,%edx
 3e0:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3e2:	83 f9 25             	cmp    $0x25,%ecx
 3e5:	74 10                	je     3f7 <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3e7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 3ea:	e8 f9 fe ff ff       	call   2e8 <putc>
        putc(fd, c);
 3ef:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 3f2:	0f be d1             	movsbl %cl,%edx
 3f5:	89 f8                	mov    %edi,%eax
 3f7:	e8 ec fe ff ff       	call   2e8 <putc>
      }
      state = 0;
 3fc:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 3fe:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3ff:	8a 0b                	mov    (%ebx),%cl
 401:	84 c9                	test   %cl,%cl
 403:	75 a9                	jne    3ae <printf+0x36>
 405:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 408:	83 c4 2c             	add    $0x2c,%esp
 40b:	5b                   	pop    %ebx
 40c:	5e                   	pop    %esi
 40d:	5f                   	pop    %edi
 40e:	5d                   	pop    %ebp
 40f:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 410:	be 25 00 00 00       	mov    $0x25,%esi
 415:	eb 90                	jmp    3a7 <printf+0x2f>
 417:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 418:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 41f:	b9 10 00 00 00       	mov    $0x10,%ecx
 424:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 427:	8b 10                	mov    (%eax),%edx
 429:	89 f8                	mov    %edi,%eax
 42b:	e8 dc fe ff ff       	call   30c <printint>
        ap++;
 430:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 434:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 436:	e9 6c ff ff ff       	jmp    3a7 <printf+0x2f>
 43b:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 43c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 43f:	8b 30                	mov    (%eax),%esi
        ap++;
 441:	83 c0 04             	add    $0x4,%eax
 444:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 447:	85 f6                	test   %esi,%esi
 449:	74 5a                	je     4a5 <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 44b:	8a 16                	mov    (%esi),%dl
 44d:	84 d2                	test   %dl,%dl
 44f:	74 14                	je     465 <printf+0xed>
 451:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 454:	0f be d2             	movsbl %dl,%edx
 457:	89 f8                	mov    %edi,%eax
 459:	e8 8a fe ff ff       	call   2e8 <putc>
          s++;
 45e:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 45f:	8a 16                	mov    (%esi),%dl
 461:	84 d2                	test   %dl,%dl
 463:	75 ef                	jne    454 <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 465:	31 f6                	xor    %esi,%esi
 467:	e9 3b ff ff ff       	jmp    3a7 <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 46c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 46f:	0f be 10             	movsbl (%eax),%edx
 472:	89 f8                	mov    %edi,%eax
 474:	e8 6f fe ff ff       	call   2e8 <putc>
        ap++;
 479:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 47d:	31 f6                	xor    %esi,%esi
 47f:	e9 23 ff ff ff       	jmp    3a7 <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 484:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 48b:	b1 0a                	mov    $0xa,%cl
 48d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 490:	8b 10                	mov    (%eax),%edx
 492:	89 f8                	mov    %edi,%eax
 494:	e8 73 fe ff ff       	call   30c <printint>
        ap++;
 499:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 49d:	66 31 f6             	xor    %si,%si
 4a0:	e9 02 ff ff ff       	jmp    3a7 <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 4a5:	be 40 06 00 00       	mov    $0x640,%esi
 4aa:	eb 9f                	jmp    44b <printf+0xd3>

000004ac <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4ac:	55                   	push   %ebp
 4ad:	89 e5                	mov    %esp,%ebp
 4af:	57                   	push   %edi
 4b0:	56                   	push   %esi
 4b1:	53                   	push   %ebx
 4b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4b5:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4b8:	a1 f8 08 00 00       	mov    0x8f8,%eax
 4bd:	8d 76 00             	lea    0x0(%esi),%esi
 4c0:	8b 10                	mov    (%eax),%edx
 4c2:	39 c8                	cmp    %ecx,%eax
 4c4:	73 04                	jae    4ca <free+0x1e>
 4c6:	39 d1                	cmp    %edx,%ecx
 4c8:	72 12                	jb     4dc <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4ca:	39 d0                	cmp    %edx,%eax
 4cc:	72 08                	jb     4d6 <free+0x2a>
 4ce:	39 c8                	cmp    %ecx,%eax
 4d0:	72 0a                	jb     4dc <free+0x30>
 4d2:	39 d1                	cmp    %edx,%ecx
 4d4:	72 06                	jb     4dc <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 4d6:	89 d0                	mov    %edx,%eax
 4d8:	eb e6                	jmp    4c0 <free+0x14>
 4da:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 4dc:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4df:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4e2:	39 d7                	cmp    %edx,%edi
 4e4:	74 19                	je     4ff <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4e6:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4e9:	8b 50 04             	mov    0x4(%eax),%edx
 4ec:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4ef:	39 f1                	cmp    %esi,%ecx
 4f1:	74 23                	je     516 <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4f3:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4f5:	a3 f8 08 00 00       	mov    %eax,0x8f8
}
 4fa:	5b                   	pop    %ebx
 4fb:	5e                   	pop    %esi
 4fc:	5f                   	pop    %edi
 4fd:	5d                   	pop    %ebp
 4fe:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 4ff:	03 72 04             	add    0x4(%edx),%esi
 502:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 505:	8b 10                	mov    (%eax),%edx
 507:	8b 12                	mov    (%edx),%edx
 509:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 50c:	8b 50 04             	mov    0x4(%eax),%edx
 50f:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 512:	39 f1                	cmp    %esi,%ecx
 514:	75 dd                	jne    4f3 <free+0x47>
    p->s.size += bp->s.size;
 516:	03 53 fc             	add    -0x4(%ebx),%edx
 519:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 51c:	8b 53 f8             	mov    -0x8(%ebx),%edx
 51f:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 521:	a3 f8 08 00 00       	mov    %eax,0x8f8
}
 526:	5b                   	pop    %ebx
 527:	5e                   	pop    %esi
 528:	5f                   	pop    %edi
 529:	5d                   	pop    %ebp
 52a:	c3                   	ret    
 52b:	90                   	nop

0000052c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 52c:	55                   	push   %ebp
 52d:	89 e5                	mov    %esp,%ebp
 52f:	57                   	push   %edi
 530:	56                   	push   %esi
 531:	53                   	push   %ebx
 532:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 535:	8b 5d 08             	mov    0x8(%ebp),%ebx
 538:	83 c3 07             	add    $0x7,%ebx
 53b:	c1 eb 03             	shr    $0x3,%ebx
 53e:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 53f:	8b 0d f8 08 00 00    	mov    0x8f8,%ecx
 545:	85 c9                	test   %ecx,%ecx
 547:	0f 84 95 00 00 00    	je     5e2 <malloc+0xb6>
 54d:	8b 01                	mov    (%ecx),%eax
 54f:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 552:	39 da                	cmp    %ebx,%edx
 554:	73 66                	jae    5bc <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 556:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 55d:	eb 0c                	jmp    56b <malloc+0x3f>
 55f:	90                   	nop
    }
    if(p == freep)
 560:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 562:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 564:	8b 50 04             	mov    0x4(%eax),%edx
 567:	39 d3                	cmp    %edx,%ebx
 569:	76 51                	jbe    5bc <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 56b:	3b 05 f8 08 00 00    	cmp    0x8f8,%eax
 571:	75 ed                	jne    560 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 573:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 579:	76 35                	jbe    5b0 <malloc+0x84>
 57b:	89 f8                	mov    %edi,%eax
 57d:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 57f:	89 04 24             	mov    %eax,(%esp)
 582:	e8 41 fd ff ff       	call   2c8 <sbrk>
  if(p == (char*)-1)
 587:	83 f8 ff             	cmp    $0xffffffff,%eax
 58a:	74 18                	je     5a4 <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 58c:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 58f:	83 c0 08             	add    $0x8,%eax
 592:	89 04 24             	mov    %eax,(%esp)
 595:	e8 12 ff ff ff       	call   4ac <free>
  return freep;
 59a:	8b 0d f8 08 00 00    	mov    0x8f8,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 5a0:	85 c9                	test   %ecx,%ecx
 5a2:	75 be                	jne    562 <malloc+0x36>
        return 0;
 5a4:	31 c0                	xor    %eax,%eax
  }
}
 5a6:	83 c4 1c             	add    $0x1c,%esp
 5a9:	5b                   	pop    %ebx
 5aa:	5e                   	pop    %esi
 5ab:	5f                   	pop    %edi
 5ac:	5d                   	pop    %ebp
 5ad:	c3                   	ret    
 5ae:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 5b0:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 5b5:	be 00 10 00 00       	mov    $0x1000,%esi
 5ba:	eb c3                	jmp    57f <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5bc:	39 d3                	cmp    %edx,%ebx
 5be:	74 1c                	je     5dc <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5c0:	29 da                	sub    %ebx,%edx
 5c2:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5c5:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5c8:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5cb:	89 0d f8 08 00 00    	mov    %ecx,0x8f8
      return (void*)(p + 1);
 5d1:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5d4:	83 c4 1c             	add    $0x1c,%esp
 5d7:	5b                   	pop    %ebx
 5d8:	5e                   	pop    %esi
 5d9:	5f                   	pop    %edi
 5da:	5d                   	pop    %ebp
 5db:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 5dc:	8b 10                	mov    (%eax),%edx
 5de:	89 11                	mov    %edx,(%ecx)
 5e0:	eb e9                	jmp    5cb <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 5e2:	c7 05 f8 08 00 00 fc 	movl   $0x8fc,0x8f8
 5e9:	08 00 00 
 5ec:	c7 05 fc 08 00 00 fc 	movl   $0x8fc,0x8fc
 5f3:	08 00 00 
    base.s.size = 0;
 5f6:	c7 05 00 09 00 00 00 	movl   $0x0,0x900
 5fd:	00 00 00 
 600:	b8 fc 08 00 00       	mov    $0x8fc,%eax
 605:	e9 4c ff ff ff       	jmp    556 <malloc+0x2a>

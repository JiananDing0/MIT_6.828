
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
  }
}

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 e4 f0             	and    $0xfffffff0,%esp
   9:	83 ec 20             	sub    $0x20,%esp
   c:	8b 7d 08             	mov    0x8(%ebp),%edi
  int fd, i;

  if(argc <= 1){
   f:	83 ff 01             	cmp    $0x1,%edi
  12:	7e 66                	jle    7a <main+0x7a>
    exit();
  }
}

int
main(int argc, char *argv[])
  14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  17:	83 c3 04             	add    $0x4,%ebx
  1a:	be 01 00 00 00       	mov    $0x1,%esi
  1f:	90                   	nop
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  20:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  27:	00 
  28:	8b 03                	mov    (%ebx),%eax
  2a:	89 04 24             	mov    %eax,(%esp)
  2d:	e8 e6 02 00 00       	call   318 <open>
  32:	85 c0                	test   %eax,%eax
  34:	78 25                	js     5b <main+0x5b>
      printf(1, "cat: cannot open %s\n", argv[i]);
      exit();
    }
    cat(fd);
  36:	89 04 24             	mov    %eax,(%esp)
  39:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  3d:	e8 4a 00 00 00       	call   8c <cat>
    close(fd);
  42:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  46:	89 04 24             	mov    %eax,(%esp)
  49:	e8 b2 02 00 00       	call   300 <close>
  if(argc <= 1){
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
  4e:	46                   	inc    %esi
  4f:	83 c3 04             	add    $0x4,%ebx
  52:	39 fe                	cmp    %edi,%esi
  54:	75 ca                	jne    20 <main+0x20>
      exit();
    }
    cat(fd);
    close(fd);
  }
  exit();
  56:	e8 7d 02 00 00       	call   2d8 <exit>
    exit();
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
      printf(1, "cat: cannot open %s\n", argv[i]);
  5b:	8b 03                	mov    (%ebx),%eax
  5d:	89 44 24 08          	mov    %eax,0x8(%esp)
  61:	c7 44 24 04 c5 06 00 	movl   $0x6c5,0x4(%esp)
  68:	00 
  69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  70:	e8 9b 03 00 00       	call   410 <printf>
      exit();
  75:	e8 5e 02 00 00       	call   2d8 <exit>
main(int argc, char *argv[])
{
  int fd, i;

  if(argc <= 1){
    cat(0);
  7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  81:	e8 06 00 00 00       	call   8c <cat>
    exit();
  86:	e8 4d 02 00 00       	call   2d8 <exit>
  8b:	90                   	nop

0000008c <cat>:

char buf[512];

void
cat(int fd)
{
  8c:	55                   	push   %ebp
  8d:	89 e5                	mov    %esp,%ebp
  8f:	56                   	push   %esi
  90:	53                   	push   %ebx
  91:	83 ec 10             	sub    $0x10,%esp
  94:	8b 75 08             	mov    0x8(%ebp),%esi
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  97:	eb 1f                	jmp    b8 <cat+0x2c>
  99:	8d 76 00             	lea    0x0(%esi),%esi
    if (write(1, buf, n) != n) {
  9c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  a0:	c7 44 24 04 00 0a 00 	movl   $0xa00,0x4(%esp)
  a7:	00 
  a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  af:	e8 44 02 00 00       	call   2f8 <write>
  b4:	39 d8                	cmp    %ebx,%eax
  b6:	75 28                	jne    e0 <cat+0x54>
void
cat(int fd)
{
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  b8:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  bf:	00 
  c0:	c7 44 24 04 00 0a 00 	movl   $0xa00,0x4(%esp)
  c7:	00 
  c8:	89 34 24             	mov    %esi,(%esp)
  cb:	e8 20 02 00 00       	call   2f0 <read>
  d0:	89 c3                	mov    %eax,%ebx
  d2:	83 f8 00             	cmp    $0x0,%eax
  d5:	7f c5                	jg     9c <cat+0x10>
    if (write(1, buf, n) != n) {
      printf(1, "cat: write error\n");
      exit();
    }
  }
  if(n < 0){
  d7:	75 20                	jne    f9 <cat+0x6d>
    printf(1, "cat: read error\n");
    exit();
  }
}
  d9:	83 c4 10             	add    $0x10,%esp
  dc:	5b                   	pop    %ebx
  dd:	5e                   	pop    %esi
  de:	5d                   	pop    %ebp
  df:	c3                   	ret    
{
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
    if (write(1, buf, n) != n) {
      printf(1, "cat: write error\n");
  e0:	c7 44 24 04 a2 06 00 	movl   $0x6a2,0x4(%esp)
  e7:	00 
  e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ef:	e8 1c 03 00 00       	call   410 <printf>
      exit();
  f4:	e8 df 01 00 00       	call   2d8 <exit>
    }
  }
  if(n < 0){
    printf(1, "cat: read error\n");
  f9:	c7 44 24 04 b4 06 00 	movl   $0x6b4,0x4(%esp)
 100:	00 
 101:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 108:	e8 03 03 00 00       	call   410 <printf>
    exit();
 10d:	e8 c6 01 00 00       	call   2d8 <exit>
 112:	90                   	nop
 113:	90                   	nop

00000114 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 114:	55                   	push   %ebp
 115:	89 e5                	mov    %esp,%ebp
 117:	53                   	push   %ebx
 118:	8b 45 08             	mov    0x8(%ebp),%eax
 11b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 11e:	31 d2                	xor    %edx,%edx
 120:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
 123:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 126:	42                   	inc    %edx
 127:	84 c9                	test   %cl,%cl
 129:	75 f5                	jne    120 <strcpy+0xc>
    ;
  return os;
}
 12b:	5b                   	pop    %ebx
 12c:	5d                   	pop    %ebp
 12d:	c3                   	ret    
 12e:	66 90                	xchg   %ax,%ax

00000130 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 130:	55                   	push   %ebp
 131:	89 e5                	mov    %esp,%ebp
 133:	56                   	push   %esi
 134:	53                   	push   %ebx
 135:	8b 4d 08             	mov    0x8(%ebp),%ecx
 138:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 13b:	8a 01                	mov    (%ecx),%al
 13d:	8a 1a                	mov    (%edx),%bl
 13f:	84 c0                	test   %al,%al
 141:	74 1d                	je     160 <strcmp+0x30>
 143:	38 d8                	cmp    %bl,%al
 145:	74 0c                	je     153 <strcmp+0x23>
 147:	eb 23                	jmp    16c <strcmp+0x3c>
 149:	8d 76 00             	lea    0x0(%esi),%esi
 14c:	41                   	inc    %ecx
 14d:	38 d8                	cmp    %bl,%al
 14f:	75 1b                	jne    16c <strcmp+0x3c>
    p++, q++;
 151:	89 f2                	mov    %esi,%edx
 153:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 156:	8a 41 01             	mov    0x1(%ecx),%al
 159:	8a 5a 01             	mov    0x1(%edx),%bl
 15c:	84 c0                	test   %al,%al
 15e:	75 ec                	jne    14c <strcmp+0x1c>
 160:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 162:	0f b6 db             	movzbl %bl,%ebx
 165:	29 d8                	sub    %ebx,%eax
}
 167:	5b                   	pop    %ebx
 168:	5e                   	pop    %esi
 169:	5d                   	pop    %ebp
 16a:	c3                   	ret    
 16b:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 16c:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 16f:	0f b6 db             	movzbl %bl,%ebx
 172:	29 d8                	sub    %ebx,%eax
}
 174:	5b                   	pop    %ebx
 175:	5e                   	pop    %esi
 176:	5d                   	pop    %ebp
 177:	c3                   	ret    

00000178 <strlen>:

uint
strlen(const char *s)
{
 178:	55                   	push   %ebp
 179:	89 e5                	mov    %esp,%ebp
 17b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 17e:	80 39 00             	cmpb   $0x0,(%ecx)
 181:	74 10                	je     193 <strlen+0x1b>
 183:	31 d2                	xor    %edx,%edx
 185:	8d 76 00             	lea    0x0(%esi),%esi
 188:	42                   	inc    %edx
 189:	89 d0                	mov    %edx,%eax
 18b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 18f:	75 f7                	jne    188 <strlen+0x10>
    ;
  return n;
}
 191:	5d                   	pop    %ebp
 192:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
 193:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
 195:	5d                   	pop    %ebp
 196:	c3                   	ret    
 197:	90                   	nop

00000198 <memset>:

void*
memset(void *dst, int c, uint n)
{
 198:	55                   	push   %ebp
 199:	89 e5                	mov    %esp,%ebp
 19b:	57                   	push   %edi
 19c:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 19f:	89 d7                	mov    %edx,%edi
 1a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1a4:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a7:	fc                   	cld    
 1a8:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1aa:	89 d0                	mov    %edx,%eax
 1ac:	5f                   	pop    %edi
 1ad:	5d                   	pop    %ebp
 1ae:	c3                   	ret    
 1af:	90                   	nop

000001b0 <strchr>:

char*
strchr(const char *s, char c)
{
 1b0:	55                   	push   %ebp
 1b1:	89 e5                	mov    %esp,%ebp
 1b3:	8b 45 08             	mov    0x8(%ebp),%eax
 1b6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 1b9:	8a 10                	mov    (%eax),%dl
 1bb:	84 d2                	test   %dl,%dl
 1bd:	75 0d                	jne    1cc <strchr+0x1c>
 1bf:	eb 13                	jmp    1d4 <strchr+0x24>
 1c1:	8d 76 00             	lea    0x0(%esi),%esi
 1c4:	8a 50 01             	mov    0x1(%eax),%dl
 1c7:	84 d2                	test   %dl,%dl
 1c9:	74 09                	je     1d4 <strchr+0x24>
 1cb:	40                   	inc    %eax
    if(*s == c)
 1cc:	38 ca                	cmp    %cl,%dl
 1ce:	75 f4                	jne    1c4 <strchr+0x14>
      return (char*)s;
  return 0;
}
 1d0:	5d                   	pop    %ebp
 1d1:	c3                   	ret    
 1d2:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
 1d4:	31 c0                	xor    %eax,%eax
}
 1d6:	5d                   	pop    %ebp
 1d7:	c3                   	ret    

000001d8 <gets>:

char*
gets(char *buf, int max)
{
 1d8:	55                   	push   %ebp
 1d9:	89 e5                	mov    %esp,%ebp
 1db:	57                   	push   %edi
 1dc:	56                   	push   %esi
 1dd:	53                   	push   %ebx
 1de:	83 ec 2c             	sub    $0x2c,%esp
 1e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e4:	31 f6                	xor    %esi,%esi
 1e6:	eb 30                	jmp    218 <gets+0x40>
    cc = read(0, &c, 1);
 1e8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1ef:	00 
 1f0:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1f3:	89 44 24 04          	mov    %eax,0x4(%esp)
 1f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1fe:	e8 ed 00 00 00       	call   2f0 <read>
    if(cc < 1)
 203:	85 c0                	test   %eax,%eax
 205:	7e 19                	jle    220 <gets+0x48>
      break;
    buf[i++] = c;
 207:	8a 45 e7             	mov    -0x19(%ebp),%al
 20a:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20e:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 210:	3c 0a                	cmp    $0xa,%al
 212:	74 0c                	je     220 <gets+0x48>
 214:	3c 0d                	cmp    $0xd,%al
 216:	74 08                	je     220 <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 218:	8d 5e 01             	lea    0x1(%esi),%ebx
 21b:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 21e:	7c c8                	jl     1e8 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 220:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 224:	89 f8                	mov    %edi,%eax
 226:	83 c4 2c             	add    $0x2c,%esp
 229:	5b                   	pop    %ebx
 22a:	5e                   	pop    %esi
 22b:	5f                   	pop    %edi
 22c:	5d                   	pop    %ebp
 22d:	c3                   	ret    
 22e:	66 90                	xchg   %ax,%ax

00000230 <stat>:

int
stat(const char *n, struct stat *st)
{
 230:	55                   	push   %ebp
 231:	89 e5                	mov    %esp,%ebp
 233:	56                   	push   %esi
 234:	53                   	push   %ebx
 235:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 238:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 23f:	00 
 240:	8b 45 08             	mov    0x8(%ebp),%eax
 243:	89 04 24             	mov    %eax,(%esp)
 246:	e8 cd 00 00 00       	call   318 <open>
 24b:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 24d:	85 c0                	test   %eax,%eax
 24f:	78 23                	js     274 <stat+0x44>
    return -1;
  r = fstat(fd, st);
 251:	8b 45 0c             	mov    0xc(%ebp),%eax
 254:	89 44 24 04          	mov    %eax,0x4(%esp)
 258:	89 1c 24             	mov    %ebx,(%esp)
 25b:	e8 d0 00 00 00       	call   330 <fstat>
 260:	89 c6                	mov    %eax,%esi
  close(fd);
 262:	89 1c 24             	mov    %ebx,(%esp)
 265:	e8 96 00 00 00       	call   300 <close>
  return r;
}
 26a:	89 f0                	mov    %esi,%eax
 26c:	83 c4 10             	add    $0x10,%esp
 26f:	5b                   	pop    %ebx
 270:	5e                   	pop    %esi
 271:	5d                   	pop    %ebp
 272:	c3                   	ret    
 273:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 274:	be ff ff ff ff       	mov    $0xffffffff,%esi
 279:	eb ef                	jmp    26a <stat+0x3a>
 27b:	90                   	nop

0000027c <atoi>:
  return r;
}

int
atoi(const char *s)
{
 27c:	55                   	push   %ebp
 27d:	89 e5                	mov    %esp,%ebp
 27f:	53                   	push   %ebx
 280:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 283:	8a 11                	mov    (%ecx),%dl
 285:	8d 42 d0             	lea    -0x30(%edx),%eax
 288:	3c 09                	cmp    $0x9,%al
 28a:	b8 00 00 00 00       	mov    $0x0,%eax
 28f:	77 18                	ja     2a9 <atoi+0x2d>
 291:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 294:	8d 04 80             	lea    (%eax,%eax,4),%eax
 297:	0f be d2             	movsbl %dl,%edx
 29a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 29e:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29f:	8a 11                	mov    (%ecx),%dl
 2a1:	8d 5a d0             	lea    -0x30(%edx),%ebx
 2a4:	80 fb 09             	cmp    $0x9,%bl
 2a7:	76 eb                	jbe    294 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 2a9:	5b                   	pop    %ebx
 2aa:	5d                   	pop    %ebp
 2ab:	c3                   	ret    

000002ac <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2ac:	55                   	push   %ebp
 2ad:	89 e5                	mov    %esp,%ebp
 2af:	56                   	push   %esi
 2b0:	53                   	push   %ebx
 2b1:	8b 45 08             	mov    0x8(%ebp),%eax
 2b4:	8b 75 0c             	mov    0xc(%ebp),%esi
 2b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2ba:	85 db                	test   %ebx,%ebx
 2bc:	7e 0d                	jle    2cb <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 2be:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 2c0:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 2c3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 2c6:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2c7:	39 da                	cmp    %ebx,%edx
 2c9:	75 f5                	jne    2c0 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 2cb:	5b                   	pop    %ebx
 2cc:	5e                   	pop    %esi
 2cd:	5d                   	pop    %ebp
 2ce:	c3                   	ret    
 2cf:	90                   	nop

000002d0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2d0:	b8 01 00 00 00       	mov    $0x1,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <exit>:
SYSCALL(exit)
 2d8:	b8 02 00 00 00       	mov    $0x2,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <wait>:
SYSCALL(wait)
 2e0:	b8 03 00 00 00       	mov    $0x3,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <pipe>:
SYSCALL(pipe)
 2e8:	b8 04 00 00 00       	mov    $0x4,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <read>:
SYSCALL(read)
 2f0:	b8 05 00 00 00       	mov    $0x5,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <write>:
SYSCALL(write)
 2f8:	b8 10 00 00 00       	mov    $0x10,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <close>:
SYSCALL(close)
 300:	b8 15 00 00 00       	mov    $0x15,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <kill>:
SYSCALL(kill)
 308:	b8 06 00 00 00       	mov    $0x6,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <exec>:
SYSCALL(exec)
 310:	b8 07 00 00 00       	mov    $0x7,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <open>:
SYSCALL(open)
 318:	b8 0f 00 00 00       	mov    $0xf,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <mknod>:
SYSCALL(mknod)
 320:	b8 11 00 00 00       	mov    $0x11,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <unlink>:
SYSCALL(unlink)
 328:	b8 12 00 00 00       	mov    $0x12,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <fstat>:
SYSCALL(fstat)
 330:	b8 08 00 00 00       	mov    $0x8,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <link>:
SYSCALL(link)
 338:	b8 13 00 00 00       	mov    $0x13,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <mkdir>:
SYSCALL(mkdir)
 340:	b8 14 00 00 00       	mov    $0x14,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <chdir>:
SYSCALL(chdir)
 348:	b8 09 00 00 00       	mov    $0x9,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <dup>:
SYSCALL(dup)
 350:	b8 0a 00 00 00       	mov    $0xa,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <getpid>:
SYSCALL(getpid)
 358:	b8 0b 00 00 00       	mov    $0xb,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <sbrk>:
SYSCALL(sbrk)
 360:	b8 0c 00 00 00       	mov    $0xc,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <sleep>:
SYSCALL(sleep)
 368:	b8 0d 00 00 00       	mov    $0xd,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <uptime>:
SYSCALL(uptime)
 370:	b8 0e 00 00 00       	mov    $0xe,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <date>:
SYSCALL(date)
 378:	b8 16 00 00 00       	mov    $0x16,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 380:	55                   	push   %ebp
 381:	89 e5                	mov    %esp,%ebp
 383:	83 ec 28             	sub    $0x28,%esp
 386:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 389:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 390:	00 
 391:	8d 55 f4             	lea    -0xc(%ebp),%edx
 394:	89 54 24 04          	mov    %edx,0x4(%esp)
 398:	89 04 24             	mov    %eax,(%esp)
 39b:	e8 58 ff ff ff       	call   2f8 <write>
}
 3a0:	c9                   	leave  
 3a1:	c3                   	ret    
 3a2:	66 90                	xchg   %ax,%ax

000003a4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3a4:	55                   	push   %ebp
 3a5:	89 e5                	mov    %esp,%ebp
 3a7:	57                   	push   %edi
 3a8:	56                   	push   %esi
 3a9:	53                   	push   %ebx
 3aa:	83 ec 1c             	sub    $0x1c,%esp
 3ad:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 3af:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
 3b4:	85 db                	test   %ebx,%ebx
 3b6:	74 04                	je     3bc <printint+0x18>
 3b8:	85 d2                	test   %edx,%edx
 3ba:	78 4a                	js     406 <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3bc:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3be:	31 db                	xor    %ebx,%ebx
 3c0:	eb 04                	jmp    3c6 <printint+0x22>
 3c2:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 3c4:	89 d3                	mov    %edx,%ebx
 3c6:	31 d2                	xor    %edx,%edx
 3c8:	f7 f1                	div    %ecx
 3ca:	8a 92 e1 06 00 00    	mov    0x6e1(%edx),%dl
 3d0:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 3d4:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 3d7:	85 c0                	test   %eax,%eax
 3d9:	75 e9                	jne    3c4 <printint+0x20>
  if(neg)
 3db:	85 ff                	test   %edi,%edi
 3dd:	74 08                	je     3e7 <printint+0x43>
    buf[i++] = '-';
 3df:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 3e4:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 3e7:	8d 5a ff             	lea    -0x1(%edx),%ebx
 3ea:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 3ec:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 3f1:	89 f0                	mov    %esi,%eax
 3f3:	e8 88 ff ff ff       	call   380 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 3f8:	4b                   	dec    %ebx
 3f9:	83 fb ff             	cmp    $0xffffffff,%ebx
 3fc:	75 ee                	jne    3ec <printint+0x48>
    putc(fd, buf[i]);
}
 3fe:	83 c4 1c             	add    $0x1c,%esp
 401:	5b                   	pop    %ebx
 402:	5e                   	pop    %esi
 403:	5f                   	pop    %edi
 404:	5d                   	pop    %ebp
 405:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 406:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 408:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 40d:	eb af                	jmp    3be <printint+0x1a>
 40f:	90                   	nop

00000410 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 410:	55                   	push   %ebp
 411:	89 e5                	mov    %esp,%ebp
 413:	57                   	push   %edi
 414:	56                   	push   %esi
 415:	53                   	push   %ebx
 416:	83 ec 2c             	sub    $0x2c,%esp
 419:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 41c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 41f:	8a 0b                	mov    (%ebx),%cl
 421:	84 c9                	test   %cl,%cl
 423:	74 7b                	je     4a0 <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 425:	8d 45 10             	lea    0x10(%ebp),%eax
 428:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 42b:	31 f6                	xor    %esi,%esi
 42d:	eb 17                	jmp    446 <printf+0x36>
 42f:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 430:	83 f9 25             	cmp    $0x25,%ecx
 433:	74 73                	je     4a8 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 435:	0f be d1             	movsbl %cl,%edx
 438:	89 f8                	mov    %edi,%eax
 43a:	e8 41 ff ff ff       	call   380 <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 43f:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 440:	8a 0b                	mov    (%ebx),%cl
 442:	84 c9                	test   %cl,%cl
 444:	74 5a                	je     4a0 <printf+0x90>
    c = fmt[i] & 0xff;
 446:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 449:	85 f6                	test   %esi,%esi
 44b:	74 e3                	je     430 <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 44d:	83 fe 25             	cmp    $0x25,%esi
 450:	75 ed                	jne    43f <printf+0x2f>
      if(c == 'd'){
 452:	83 f9 64             	cmp    $0x64,%ecx
 455:	0f 84 c1 00 00 00    	je     51c <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 45b:	83 f9 78             	cmp    $0x78,%ecx
 45e:	74 50                	je     4b0 <printf+0xa0>
 460:	83 f9 70             	cmp    $0x70,%ecx
 463:	74 4b                	je     4b0 <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 465:	83 f9 73             	cmp    $0x73,%ecx
 468:	74 6a                	je     4d4 <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 46a:	83 f9 63             	cmp    $0x63,%ecx
 46d:	0f 84 91 00 00 00    	je     504 <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 473:	ba 25 00 00 00       	mov    $0x25,%edx
 478:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 47a:	83 f9 25             	cmp    $0x25,%ecx
 47d:	74 10                	je     48f <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 47f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 482:	e8 f9 fe ff ff       	call   380 <putc>
        putc(fd, c);
 487:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 48a:	0f be d1             	movsbl %cl,%edx
 48d:	89 f8                	mov    %edi,%eax
 48f:	e8 ec fe ff ff       	call   380 <putc>
      }
      state = 0;
 494:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 496:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 497:	8a 0b                	mov    (%ebx),%cl
 499:	84 c9                	test   %cl,%cl
 49b:	75 a9                	jne    446 <printf+0x36>
 49d:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 4a0:	83 c4 2c             	add    $0x2c,%esp
 4a3:	5b                   	pop    %ebx
 4a4:	5e                   	pop    %esi
 4a5:	5f                   	pop    %edi
 4a6:	5d                   	pop    %ebp
 4a7:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 4a8:	be 25 00 00 00       	mov    $0x25,%esi
 4ad:	eb 90                	jmp    43f <printf+0x2f>
 4af:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 4b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 4b7:	b9 10 00 00 00       	mov    $0x10,%ecx
 4bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4bf:	8b 10                	mov    (%eax),%edx
 4c1:	89 f8                	mov    %edi,%eax
 4c3:	e8 dc fe ff ff       	call   3a4 <printint>
        ap++;
 4c8:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4cc:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 4ce:	e9 6c ff ff ff       	jmp    43f <printf+0x2f>
 4d3:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 4d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4d7:	8b 30                	mov    (%eax),%esi
        ap++;
 4d9:	83 c0 04             	add    $0x4,%eax
 4dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4df:	85 f6                	test   %esi,%esi
 4e1:	74 5a                	je     53d <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 4e3:	8a 16                	mov    (%esi),%dl
 4e5:	84 d2                	test   %dl,%dl
 4e7:	74 14                	je     4fd <printf+0xed>
 4e9:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 4ec:	0f be d2             	movsbl %dl,%edx
 4ef:	89 f8                	mov    %edi,%eax
 4f1:	e8 8a fe ff ff       	call   380 <putc>
          s++;
 4f6:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 4f7:	8a 16                	mov    (%esi),%dl
 4f9:	84 d2                	test   %dl,%dl
 4fb:	75 ef                	jne    4ec <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4fd:	31 f6                	xor    %esi,%esi
 4ff:	e9 3b ff ff ff       	jmp    43f <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 504:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 507:	0f be 10             	movsbl (%eax),%edx
 50a:	89 f8                	mov    %edi,%eax
 50c:	e8 6f fe ff ff       	call   380 <putc>
        ap++;
 511:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 515:	31 f6                	xor    %esi,%esi
 517:	e9 23 ff ff ff       	jmp    43f <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 51c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 523:	b1 0a                	mov    $0xa,%cl
 525:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 528:	8b 10                	mov    (%eax),%edx
 52a:	89 f8                	mov    %edi,%eax
 52c:	e8 73 fe ff ff       	call   3a4 <printint>
        ap++;
 531:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 535:	66 31 f6             	xor    %si,%si
 538:	e9 02 ff ff ff       	jmp    43f <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 53d:	be da 06 00 00       	mov    $0x6da,%esi
 542:	eb 9f                	jmp    4e3 <printf+0xd3>

00000544 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 544:	55                   	push   %ebp
 545:	89 e5                	mov    %esp,%ebp
 547:	57                   	push   %edi
 548:	56                   	push   %esi
 549:	53                   	push   %ebx
 54a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 54d:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 550:	a1 e0 09 00 00       	mov    0x9e0,%eax
 555:	8d 76 00             	lea    0x0(%esi),%esi
 558:	8b 10                	mov    (%eax),%edx
 55a:	39 c8                	cmp    %ecx,%eax
 55c:	73 04                	jae    562 <free+0x1e>
 55e:	39 d1                	cmp    %edx,%ecx
 560:	72 12                	jb     574 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 562:	39 d0                	cmp    %edx,%eax
 564:	72 08                	jb     56e <free+0x2a>
 566:	39 c8                	cmp    %ecx,%eax
 568:	72 0a                	jb     574 <free+0x30>
 56a:	39 d1                	cmp    %edx,%ecx
 56c:	72 06                	jb     574 <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 56e:	89 d0                	mov    %edx,%eax
 570:	eb e6                	jmp    558 <free+0x14>
 572:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 574:	8b 73 fc             	mov    -0x4(%ebx),%esi
 577:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 57a:	39 d7                	cmp    %edx,%edi
 57c:	74 19                	je     597 <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 57e:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 581:	8b 50 04             	mov    0x4(%eax),%edx
 584:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 587:	39 f1                	cmp    %esi,%ecx
 589:	74 23                	je     5ae <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 58b:	89 08                	mov    %ecx,(%eax)
  freep = p;
 58d:	a3 e0 09 00 00       	mov    %eax,0x9e0
}
 592:	5b                   	pop    %ebx
 593:	5e                   	pop    %esi
 594:	5f                   	pop    %edi
 595:	5d                   	pop    %ebp
 596:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 597:	03 72 04             	add    0x4(%edx),%esi
 59a:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 59d:	8b 10                	mov    (%eax),%edx
 59f:	8b 12                	mov    (%edx),%edx
 5a1:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 5a4:	8b 50 04             	mov    0x4(%eax),%edx
 5a7:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5aa:	39 f1                	cmp    %esi,%ecx
 5ac:	75 dd                	jne    58b <free+0x47>
    p->s.size += bp->s.size;
 5ae:	03 53 fc             	add    -0x4(%ebx),%edx
 5b1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5b4:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5b7:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 5b9:	a3 e0 09 00 00       	mov    %eax,0x9e0
}
 5be:	5b                   	pop    %ebx
 5bf:	5e                   	pop    %esi
 5c0:	5f                   	pop    %edi
 5c1:	5d                   	pop    %ebp
 5c2:	c3                   	ret    
 5c3:	90                   	nop

000005c4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 5c4:	55                   	push   %ebp
 5c5:	89 e5                	mov    %esp,%ebp
 5c7:	57                   	push   %edi
 5c8:	56                   	push   %esi
 5c9:	53                   	push   %ebx
 5ca:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
 5d0:	83 c3 07             	add    $0x7,%ebx
 5d3:	c1 eb 03             	shr    $0x3,%ebx
 5d6:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 5d7:	8b 0d e0 09 00 00    	mov    0x9e0,%ecx
 5dd:	85 c9                	test   %ecx,%ecx
 5df:	0f 84 95 00 00 00    	je     67a <malloc+0xb6>
 5e5:	8b 01                	mov    (%ecx),%eax
 5e7:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 5ea:	39 da                	cmp    %ebx,%edx
 5ec:	73 66                	jae    654 <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 5ee:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 5f5:	eb 0c                	jmp    603 <malloc+0x3f>
 5f7:	90                   	nop
    }
    if(p == freep)
 5f8:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5fa:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 5fc:	8b 50 04             	mov    0x4(%eax),%edx
 5ff:	39 d3                	cmp    %edx,%ebx
 601:	76 51                	jbe    654 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 603:	3b 05 e0 09 00 00    	cmp    0x9e0,%eax
 609:	75 ed                	jne    5f8 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 60b:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 611:	76 35                	jbe    648 <malloc+0x84>
 613:	89 f8                	mov    %edi,%eax
 615:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 617:	89 04 24             	mov    %eax,(%esp)
 61a:	e8 41 fd ff ff       	call   360 <sbrk>
  if(p == (char*)-1)
 61f:	83 f8 ff             	cmp    $0xffffffff,%eax
 622:	74 18                	je     63c <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 624:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 627:	83 c0 08             	add    $0x8,%eax
 62a:	89 04 24             	mov    %eax,(%esp)
 62d:	e8 12 ff ff ff       	call   544 <free>
  return freep;
 632:	8b 0d e0 09 00 00    	mov    0x9e0,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 638:	85 c9                	test   %ecx,%ecx
 63a:	75 be                	jne    5fa <malloc+0x36>
        return 0;
 63c:	31 c0                	xor    %eax,%eax
  }
}
 63e:	83 c4 1c             	add    $0x1c,%esp
 641:	5b                   	pop    %ebx
 642:	5e                   	pop    %esi
 643:	5f                   	pop    %edi
 644:	5d                   	pop    %ebp
 645:	c3                   	ret    
 646:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 648:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 64d:	be 00 10 00 00       	mov    $0x1000,%esi
 652:	eb c3                	jmp    617 <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 654:	39 d3                	cmp    %edx,%ebx
 656:	74 1c                	je     674 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 658:	29 da                	sub    %ebx,%edx
 65a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 65d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 660:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 663:	89 0d e0 09 00 00    	mov    %ecx,0x9e0
      return (void*)(p + 1);
 669:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 66c:	83 c4 1c             	add    $0x1c,%esp
 66f:	5b                   	pop    %ebx
 670:	5e                   	pop    %esi
 671:	5f                   	pop    %edi
 672:	5d                   	pop    %ebp
 673:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 674:	8b 10                	mov    (%eax),%edx
 676:	89 11                	mov    %edx,(%ecx)
 678:	eb e9                	jmp    663 <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 67a:	c7 05 e0 09 00 00 e4 	movl   $0x9e4,0x9e0
 681:	09 00 00 
 684:	c7 05 e4 09 00 00 e4 	movl   $0x9e4,0x9e4
 68b:	09 00 00 
    base.s.size = 0;
 68e:	c7 05 e8 09 00 00 00 	movl   $0x0,0x9e8
 695:	00 00 00 
 698:	b8 e4 09 00 00       	mov    $0x9e4,%eax
 69d:	e9 4c ff ff ff       	jmp    5ee <malloc+0x2a>

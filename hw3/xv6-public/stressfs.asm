
_stressfs:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 e4 f0             	and    $0xfffffff0,%esp
   9:	81 ec 30 02 00 00    	sub    $0x230,%esp
  int fd, i;
  char path[] = "stressfs0";
   f:	8d 9c 24 26 02 00 00 	lea    0x226(%esp),%ebx
  16:	be e1 06 00 00       	mov    $0x6e1,%esi
  1b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  20:	89 df                	mov    %ebx,%edi
  22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  char data[512];

  printf(1, "stressfs starting\n");
  24:	c7 44 24 04 be 06 00 	movl   $0x6be,0x4(%esp)
  2b:	00 
  2c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  33:	e8 f4 03 00 00       	call   42c <printf>
  memset(data, 'a', sizeof(data));
  38:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  3f:	00 
  40:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  47:	00 
  48:	8d 7c 24 26          	lea    0x26(%esp),%edi
  4c:	89 3c 24             	mov    %edi,(%esp)
  4f:	e8 60 01 00 00       	call   1b4 <memset>

  for(i = 0; i < 4; i++)
  54:	31 f6                	xor    %esi,%esi
    if(fork() > 0)
  56:	e8 91 02 00 00       	call   2ec <fork>
  5b:	85 c0                	test   %eax,%eax
  5d:	0f 8f c6 00 00 00    	jg     129 <main+0x129>
  char data[512];

  printf(1, "stressfs starting\n");
  memset(data, 'a', sizeof(data));

  for(i = 0; i < 4; i++)
  63:	46                   	inc    %esi
  64:	83 fe 04             	cmp    $0x4,%esi
  67:	75 ed                	jne    56 <main+0x56>
  69:	b0 04                	mov    $0x4,%al
    if(fork() > 0)
      break;

  printf(1, "write %d\n", i);
  6b:	89 74 24 08          	mov    %esi,0x8(%esp)
  6f:	c7 44 24 04 d1 06 00 	movl   $0x6d1,0x4(%esp)
  76:	00 
  77:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7e:	88 44 24 18          	mov    %al,0x18(%esp)
  82:	e8 a5 03 00 00       	call   42c <printf>

  path[8] += i;
  87:	8a 44 24 18          	mov    0x18(%esp),%al
  8b:	00 84 24 2e 02 00 00 	add    %al,0x22e(%esp)
  fd = open(path, O_CREATE | O_RDWR);
  92:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  99:	00 
  9a:	89 1c 24             	mov    %ebx,(%esp)
  9d:	e8 92 02 00 00       	call   334 <open>
  a2:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  a6:	be 14 00 00 00       	mov    $0x14,%esi
  ab:	90                   	nop
  for(i = 0; i < 20; i++)
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  ac:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  b3:	00 
  b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  b8:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  bc:	89 04 24             	mov    %eax,(%esp)
  bf:	e8 50 02 00 00       	call   314 <write>

  printf(1, "write %d\n", i);

  path[8] += i;
  fd = open(path, O_CREATE | O_RDWR);
  for(i = 0; i < 20; i++)
  c4:	4e                   	dec    %esi
  c5:	75 e5                	jne    ac <main+0xac>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  close(fd);
  c7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  cb:	89 04 24             	mov    %eax,(%esp)
  ce:	e8 49 02 00 00       	call   31c <close>

  printf(1, "read\n");
  d3:	c7 44 24 04 db 06 00 	movl   $0x6db,0x4(%esp)
  da:	00 
  db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e2:	e8 45 03 00 00       	call   42c <printf>

  fd = open(path, O_RDONLY);
  e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  ee:	00 
  ef:	89 1c 24             	mov    %ebx,(%esp)
  f2:	e8 3d 02 00 00       	call   334 <open>
  f7:	89 c6                	mov    %eax,%esi
  f9:	bb 14 00 00 00       	mov    $0x14,%ebx
  fe:	66 90                	xchg   %ax,%ax
  for (i = 0; i < 20; i++)
    read(fd, data, sizeof(data));
 100:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
 107:	00 
 108:	89 7c 24 04          	mov    %edi,0x4(%esp)
 10c:	89 34 24             	mov    %esi,(%esp)
 10f:	e8 f8 01 00 00       	call   30c <read>
  close(fd);

  printf(1, "read\n");

  fd = open(path, O_RDONLY);
  for (i = 0; i < 20; i++)
 114:	4b                   	dec    %ebx
 115:	75 e9                	jne    100 <main+0x100>
    read(fd, data, sizeof(data));
  close(fd);
 117:	89 34 24             	mov    %esi,(%esp)
 11a:	e8 fd 01 00 00       	call   31c <close>

  wait();
 11f:	e8 d8 01 00 00       	call   2fc <wait>

  exit();
 124:	e8 cb 01 00 00       	call   2f4 <exit>

  printf(1, "stressfs starting\n");
  memset(data, 'a', sizeof(data));

  for(i = 0; i < 4; i++)
    if(fork() > 0)
 129:	89 f0                	mov    %esi,%eax
 12b:	e9 3b ff ff ff       	jmp    6b <main+0x6b>

00000130 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 130:	55                   	push   %ebp
 131:	89 e5                	mov    %esp,%ebp
 133:	53                   	push   %ebx
 134:	8b 45 08             	mov    0x8(%ebp),%eax
 137:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 13a:	31 d2                	xor    %edx,%edx
 13c:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
 13f:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 142:	42                   	inc    %edx
 143:	84 c9                	test   %cl,%cl
 145:	75 f5                	jne    13c <strcpy+0xc>
    ;
  return os;
}
 147:	5b                   	pop    %ebx
 148:	5d                   	pop    %ebp
 149:	c3                   	ret    
 14a:	66 90                	xchg   %ax,%ax

0000014c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 14c:	55                   	push   %ebp
 14d:	89 e5                	mov    %esp,%ebp
 14f:	56                   	push   %esi
 150:	53                   	push   %ebx
 151:	8b 4d 08             	mov    0x8(%ebp),%ecx
 154:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 157:	8a 01                	mov    (%ecx),%al
 159:	8a 1a                	mov    (%edx),%bl
 15b:	84 c0                	test   %al,%al
 15d:	74 1d                	je     17c <strcmp+0x30>
 15f:	38 d8                	cmp    %bl,%al
 161:	74 0c                	je     16f <strcmp+0x23>
 163:	eb 23                	jmp    188 <strcmp+0x3c>
 165:	8d 76 00             	lea    0x0(%esi),%esi
 168:	41                   	inc    %ecx
 169:	38 d8                	cmp    %bl,%al
 16b:	75 1b                	jne    188 <strcmp+0x3c>
    p++, q++;
 16d:	89 f2                	mov    %esi,%edx
 16f:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 172:	8a 41 01             	mov    0x1(%ecx),%al
 175:	8a 5a 01             	mov    0x1(%edx),%bl
 178:	84 c0                	test   %al,%al
 17a:	75 ec                	jne    168 <strcmp+0x1c>
 17c:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 17e:	0f b6 db             	movzbl %bl,%ebx
 181:	29 d8                	sub    %ebx,%eax
}
 183:	5b                   	pop    %ebx
 184:	5e                   	pop    %esi
 185:	5d                   	pop    %ebp
 186:	c3                   	ret    
 187:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 188:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 18b:	0f b6 db             	movzbl %bl,%ebx
 18e:	29 d8                	sub    %ebx,%eax
}
 190:	5b                   	pop    %ebx
 191:	5e                   	pop    %esi
 192:	5d                   	pop    %ebp
 193:	c3                   	ret    

00000194 <strlen>:

uint
strlen(const char *s)
{
 194:	55                   	push   %ebp
 195:	89 e5                	mov    %esp,%ebp
 197:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 19a:	80 39 00             	cmpb   $0x0,(%ecx)
 19d:	74 10                	je     1af <strlen+0x1b>
 19f:	31 d2                	xor    %edx,%edx
 1a1:	8d 76 00             	lea    0x0(%esi),%esi
 1a4:	42                   	inc    %edx
 1a5:	89 d0                	mov    %edx,%eax
 1a7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 1ab:	75 f7                	jne    1a4 <strlen+0x10>
    ;
  return n;
}
 1ad:	5d                   	pop    %ebp
 1ae:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
 1af:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
 1b1:	5d                   	pop    %ebp
 1b2:	c3                   	ret    
 1b3:	90                   	nop

000001b4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1b4:	55                   	push   %ebp
 1b5:	89 e5                	mov    %esp,%ebp
 1b7:	57                   	push   %edi
 1b8:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1bb:	89 d7                	mov    %edx,%edi
 1bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c3:	fc                   	cld    
 1c4:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1c6:	89 d0                	mov    %edx,%eax
 1c8:	5f                   	pop    %edi
 1c9:	5d                   	pop    %ebp
 1ca:	c3                   	ret    
 1cb:	90                   	nop

000001cc <strchr>:

char*
strchr(const char *s, char c)
{
 1cc:	55                   	push   %ebp
 1cd:	89 e5                	mov    %esp,%ebp
 1cf:	8b 45 08             	mov    0x8(%ebp),%eax
 1d2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 1d5:	8a 10                	mov    (%eax),%dl
 1d7:	84 d2                	test   %dl,%dl
 1d9:	75 0d                	jne    1e8 <strchr+0x1c>
 1db:	eb 13                	jmp    1f0 <strchr+0x24>
 1dd:	8d 76 00             	lea    0x0(%esi),%esi
 1e0:	8a 50 01             	mov    0x1(%eax),%dl
 1e3:	84 d2                	test   %dl,%dl
 1e5:	74 09                	je     1f0 <strchr+0x24>
 1e7:	40                   	inc    %eax
    if(*s == c)
 1e8:	38 ca                	cmp    %cl,%dl
 1ea:	75 f4                	jne    1e0 <strchr+0x14>
      return (char*)s;
  return 0;
}
 1ec:	5d                   	pop    %ebp
 1ed:	c3                   	ret    
 1ee:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
 1f0:	31 c0                	xor    %eax,%eax
}
 1f2:	5d                   	pop    %ebp
 1f3:	c3                   	ret    

000001f4 <gets>:

char*
gets(char *buf, int max)
{
 1f4:	55                   	push   %ebp
 1f5:	89 e5                	mov    %esp,%ebp
 1f7:	57                   	push   %edi
 1f8:	56                   	push   %esi
 1f9:	53                   	push   %ebx
 1fa:	83 ec 2c             	sub    $0x2c,%esp
 1fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 200:	31 f6                	xor    %esi,%esi
 202:	eb 30                	jmp    234 <gets+0x40>
    cc = read(0, &c, 1);
 204:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 20b:	00 
 20c:	8d 45 e7             	lea    -0x19(%ebp),%eax
 20f:	89 44 24 04          	mov    %eax,0x4(%esp)
 213:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 21a:	e8 ed 00 00 00       	call   30c <read>
    if(cc < 1)
 21f:	85 c0                	test   %eax,%eax
 221:	7e 19                	jle    23c <gets+0x48>
      break;
    buf[i++] = c;
 223:	8a 45 e7             	mov    -0x19(%ebp),%al
 226:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 22a:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 22c:	3c 0a                	cmp    $0xa,%al
 22e:	74 0c                	je     23c <gets+0x48>
 230:	3c 0d                	cmp    $0xd,%al
 232:	74 08                	je     23c <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 234:	8d 5e 01             	lea    0x1(%esi),%ebx
 237:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 23a:	7c c8                	jl     204 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 23c:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 240:	89 f8                	mov    %edi,%eax
 242:	83 c4 2c             	add    $0x2c,%esp
 245:	5b                   	pop    %ebx
 246:	5e                   	pop    %esi
 247:	5f                   	pop    %edi
 248:	5d                   	pop    %ebp
 249:	c3                   	ret    
 24a:	66 90                	xchg   %ax,%ax

0000024c <stat>:

int
stat(const char *n, struct stat *st)
{
 24c:	55                   	push   %ebp
 24d:	89 e5                	mov    %esp,%ebp
 24f:	56                   	push   %esi
 250:	53                   	push   %ebx
 251:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 254:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 25b:	00 
 25c:	8b 45 08             	mov    0x8(%ebp),%eax
 25f:	89 04 24             	mov    %eax,(%esp)
 262:	e8 cd 00 00 00       	call   334 <open>
 267:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 269:	85 c0                	test   %eax,%eax
 26b:	78 23                	js     290 <stat+0x44>
    return -1;
  r = fstat(fd, st);
 26d:	8b 45 0c             	mov    0xc(%ebp),%eax
 270:	89 44 24 04          	mov    %eax,0x4(%esp)
 274:	89 1c 24             	mov    %ebx,(%esp)
 277:	e8 d0 00 00 00       	call   34c <fstat>
 27c:	89 c6                	mov    %eax,%esi
  close(fd);
 27e:	89 1c 24             	mov    %ebx,(%esp)
 281:	e8 96 00 00 00       	call   31c <close>
  return r;
}
 286:	89 f0                	mov    %esi,%eax
 288:	83 c4 10             	add    $0x10,%esp
 28b:	5b                   	pop    %ebx
 28c:	5e                   	pop    %esi
 28d:	5d                   	pop    %ebp
 28e:	c3                   	ret    
 28f:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 290:	be ff ff ff ff       	mov    $0xffffffff,%esi
 295:	eb ef                	jmp    286 <stat+0x3a>
 297:	90                   	nop

00000298 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 298:	55                   	push   %ebp
 299:	89 e5                	mov    %esp,%ebp
 29b:	53                   	push   %ebx
 29c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29f:	8a 11                	mov    (%ecx),%dl
 2a1:	8d 42 d0             	lea    -0x30(%edx),%eax
 2a4:	3c 09                	cmp    $0x9,%al
 2a6:	b8 00 00 00 00       	mov    $0x0,%eax
 2ab:	77 18                	ja     2c5 <atoi+0x2d>
 2ad:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 2b0:	8d 04 80             	lea    (%eax,%eax,4),%eax
 2b3:	0f be d2             	movsbl %dl,%edx
 2b6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 2ba:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2bb:	8a 11                	mov    (%ecx),%dl
 2bd:	8d 5a d0             	lea    -0x30(%edx),%ebx
 2c0:	80 fb 09             	cmp    $0x9,%bl
 2c3:	76 eb                	jbe    2b0 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 2c5:	5b                   	pop    %ebx
 2c6:	5d                   	pop    %ebp
 2c7:	c3                   	ret    

000002c8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2c8:	55                   	push   %ebp
 2c9:	89 e5                	mov    %esp,%ebp
 2cb:	56                   	push   %esi
 2cc:	53                   	push   %ebx
 2cd:	8b 45 08             	mov    0x8(%ebp),%eax
 2d0:	8b 75 0c             	mov    0xc(%ebp),%esi
 2d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2d6:	85 db                	test   %ebx,%ebx
 2d8:	7e 0d                	jle    2e7 <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 2da:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 2dc:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 2df:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 2e2:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2e3:	39 da                	cmp    %ebx,%edx
 2e5:	75 f5                	jne    2dc <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 2e7:	5b                   	pop    %ebx
 2e8:	5e                   	pop    %esi
 2e9:	5d                   	pop    %ebp
 2ea:	c3                   	ret    
 2eb:	90                   	nop

000002ec <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2ec:	b8 01 00 00 00       	mov    $0x1,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <exit>:
SYSCALL(exit)
 2f4:	b8 02 00 00 00       	mov    $0x2,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <wait>:
SYSCALL(wait)
 2fc:	b8 03 00 00 00       	mov    $0x3,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <pipe>:
SYSCALL(pipe)
 304:	b8 04 00 00 00       	mov    $0x4,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <read>:
SYSCALL(read)
 30c:	b8 05 00 00 00       	mov    $0x5,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <write>:
SYSCALL(write)
 314:	b8 10 00 00 00       	mov    $0x10,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <close>:
SYSCALL(close)
 31c:	b8 15 00 00 00       	mov    $0x15,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <kill>:
SYSCALL(kill)
 324:	b8 06 00 00 00       	mov    $0x6,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <exec>:
SYSCALL(exec)
 32c:	b8 07 00 00 00       	mov    $0x7,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <open>:
SYSCALL(open)
 334:	b8 0f 00 00 00       	mov    $0xf,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <mknod>:
SYSCALL(mknod)
 33c:	b8 11 00 00 00       	mov    $0x11,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <unlink>:
SYSCALL(unlink)
 344:	b8 12 00 00 00       	mov    $0x12,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <fstat>:
SYSCALL(fstat)
 34c:	b8 08 00 00 00       	mov    $0x8,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <link>:
SYSCALL(link)
 354:	b8 13 00 00 00       	mov    $0x13,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <mkdir>:
SYSCALL(mkdir)
 35c:	b8 14 00 00 00       	mov    $0x14,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <chdir>:
SYSCALL(chdir)
 364:	b8 09 00 00 00       	mov    $0x9,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <dup>:
SYSCALL(dup)
 36c:	b8 0a 00 00 00       	mov    $0xa,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <getpid>:
SYSCALL(getpid)
 374:	b8 0b 00 00 00       	mov    $0xb,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <sbrk>:
SYSCALL(sbrk)
 37c:	b8 0c 00 00 00       	mov    $0xc,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <sleep>:
SYSCALL(sleep)
 384:	b8 0d 00 00 00       	mov    $0xd,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <uptime>:
SYSCALL(uptime)
 38c:	b8 0e 00 00 00       	mov    $0xe,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <date>:
SYSCALL(date)
 394:	b8 16 00 00 00       	mov    $0x16,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 39c:	55                   	push   %ebp
 39d:	89 e5                	mov    %esp,%ebp
 39f:	83 ec 28             	sub    $0x28,%esp
 3a2:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 3a5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3ac:	00 
 3ad:	8d 55 f4             	lea    -0xc(%ebp),%edx
 3b0:	89 54 24 04          	mov    %edx,0x4(%esp)
 3b4:	89 04 24             	mov    %eax,(%esp)
 3b7:	e8 58 ff ff ff       	call   314 <write>
}
 3bc:	c9                   	leave  
 3bd:	c3                   	ret    
 3be:	66 90                	xchg   %ax,%ax

000003c0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3c0:	55                   	push   %ebp
 3c1:	89 e5                	mov    %esp,%ebp
 3c3:	57                   	push   %edi
 3c4:	56                   	push   %esi
 3c5:	53                   	push   %ebx
 3c6:	83 ec 1c             	sub    $0x1c,%esp
 3c9:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 3cb:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
 3d0:	85 db                	test   %ebx,%ebx
 3d2:	74 04                	je     3d8 <printint+0x18>
 3d4:	85 d2                	test   %edx,%edx
 3d6:	78 4a                	js     422 <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3d8:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3da:	31 db                	xor    %ebx,%ebx
 3dc:	eb 04                	jmp    3e2 <printint+0x22>
 3de:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 3e0:	89 d3                	mov    %edx,%ebx
 3e2:	31 d2                	xor    %edx,%edx
 3e4:	f7 f1                	div    %ecx
 3e6:	8a 92 f2 06 00 00    	mov    0x6f2(%edx),%dl
 3ec:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 3f0:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 3f3:	85 c0                	test   %eax,%eax
 3f5:	75 e9                	jne    3e0 <printint+0x20>
  if(neg)
 3f7:	85 ff                	test   %edi,%edi
 3f9:	74 08                	je     403 <printint+0x43>
    buf[i++] = '-';
 3fb:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 400:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 403:	8d 5a ff             	lea    -0x1(%edx),%ebx
 406:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 408:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 40d:	89 f0                	mov    %esi,%eax
 40f:	e8 88 ff ff ff       	call   39c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 414:	4b                   	dec    %ebx
 415:	83 fb ff             	cmp    $0xffffffff,%ebx
 418:	75 ee                	jne    408 <printint+0x48>
    putc(fd, buf[i]);
}
 41a:	83 c4 1c             	add    $0x1c,%esp
 41d:	5b                   	pop    %ebx
 41e:	5e                   	pop    %esi
 41f:	5f                   	pop    %edi
 420:	5d                   	pop    %ebp
 421:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 422:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 424:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 429:	eb af                	jmp    3da <printint+0x1a>
 42b:	90                   	nop

0000042c <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 42c:	55                   	push   %ebp
 42d:	89 e5                	mov    %esp,%ebp
 42f:	57                   	push   %edi
 430:	56                   	push   %esi
 431:	53                   	push   %ebx
 432:	83 ec 2c             	sub    $0x2c,%esp
 435:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 438:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 43b:	8a 0b                	mov    (%ebx),%cl
 43d:	84 c9                	test   %cl,%cl
 43f:	74 7b                	je     4bc <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 441:	8d 45 10             	lea    0x10(%ebp),%eax
 444:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 447:	31 f6                	xor    %esi,%esi
 449:	eb 17                	jmp    462 <printf+0x36>
 44b:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 44c:	83 f9 25             	cmp    $0x25,%ecx
 44f:	74 73                	je     4c4 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 451:	0f be d1             	movsbl %cl,%edx
 454:	89 f8                	mov    %edi,%eax
 456:	e8 41 ff ff ff       	call   39c <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 45b:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 45c:	8a 0b                	mov    (%ebx),%cl
 45e:	84 c9                	test   %cl,%cl
 460:	74 5a                	je     4bc <printf+0x90>
    c = fmt[i] & 0xff;
 462:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 465:	85 f6                	test   %esi,%esi
 467:	74 e3                	je     44c <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 469:	83 fe 25             	cmp    $0x25,%esi
 46c:	75 ed                	jne    45b <printf+0x2f>
      if(c == 'd'){
 46e:	83 f9 64             	cmp    $0x64,%ecx
 471:	0f 84 c1 00 00 00    	je     538 <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 477:	83 f9 78             	cmp    $0x78,%ecx
 47a:	74 50                	je     4cc <printf+0xa0>
 47c:	83 f9 70             	cmp    $0x70,%ecx
 47f:	74 4b                	je     4cc <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 481:	83 f9 73             	cmp    $0x73,%ecx
 484:	74 6a                	je     4f0 <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 486:	83 f9 63             	cmp    $0x63,%ecx
 489:	0f 84 91 00 00 00    	je     520 <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 48f:	ba 25 00 00 00       	mov    $0x25,%edx
 494:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 496:	83 f9 25             	cmp    $0x25,%ecx
 499:	74 10                	je     4ab <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 49b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 49e:	e8 f9 fe ff ff       	call   39c <putc>
        putc(fd, c);
 4a3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 4a6:	0f be d1             	movsbl %cl,%edx
 4a9:	89 f8                	mov    %edi,%eax
 4ab:	e8 ec fe ff ff       	call   39c <putc>
      }
      state = 0;
 4b0:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 4b2:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 4b3:	8a 0b                	mov    (%ebx),%cl
 4b5:	84 c9                	test   %cl,%cl
 4b7:	75 a9                	jne    462 <printf+0x36>
 4b9:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 4bc:	83 c4 2c             	add    $0x2c,%esp
 4bf:	5b                   	pop    %ebx
 4c0:	5e                   	pop    %esi
 4c1:	5f                   	pop    %edi
 4c2:	5d                   	pop    %ebp
 4c3:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 4c4:	be 25 00 00 00       	mov    $0x25,%esi
 4c9:	eb 90                	jmp    45b <printf+0x2f>
 4cb:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 4cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 4d3:	b9 10 00 00 00       	mov    $0x10,%ecx
 4d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4db:	8b 10                	mov    (%eax),%edx
 4dd:	89 f8                	mov    %edi,%eax
 4df:	e8 dc fe ff ff       	call   3c0 <printint>
        ap++;
 4e4:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4e8:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 4ea:	e9 6c ff ff ff       	jmp    45b <printf+0x2f>
 4ef:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 4f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4f3:	8b 30                	mov    (%eax),%esi
        ap++;
 4f5:	83 c0 04             	add    $0x4,%eax
 4f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4fb:	85 f6                	test   %esi,%esi
 4fd:	74 5a                	je     559 <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 4ff:	8a 16                	mov    (%esi),%dl
 501:	84 d2                	test   %dl,%dl
 503:	74 14                	je     519 <printf+0xed>
 505:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 508:	0f be d2             	movsbl %dl,%edx
 50b:	89 f8                	mov    %edi,%eax
 50d:	e8 8a fe ff ff       	call   39c <putc>
          s++;
 512:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 513:	8a 16                	mov    (%esi),%dl
 515:	84 d2                	test   %dl,%dl
 517:	75 ef                	jne    508 <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 519:	31 f6                	xor    %esi,%esi
 51b:	e9 3b ff ff ff       	jmp    45b <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 520:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 523:	0f be 10             	movsbl (%eax),%edx
 526:	89 f8                	mov    %edi,%eax
 528:	e8 6f fe ff ff       	call   39c <putc>
        ap++;
 52d:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 531:	31 f6                	xor    %esi,%esi
 533:	e9 23 ff ff ff       	jmp    45b <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 538:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 53f:	b1 0a                	mov    $0xa,%cl
 541:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 544:	8b 10                	mov    (%eax),%edx
 546:	89 f8                	mov    %edi,%eax
 548:	e8 73 fe ff ff       	call   3c0 <printint>
        ap++;
 54d:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 551:	66 31 f6             	xor    %si,%si
 554:	e9 02 ff ff ff       	jmp    45b <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 559:	be eb 06 00 00       	mov    $0x6eb,%esi
 55e:	eb 9f                	jmp    4ff <printf+0xd3>

00000560 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 560:	55                   	push   %ebp
 561:	89 e5                	mov    %esp,%ebp
 563:	57                   	push   %edi
 564:	56                   	push   %esi
 565:	53                   	push   %ebx
 566:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 569:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 56c:	a1 a8 09 00 00       	mov    0x9a8,%eax
 571:	8d 76 00             	lea    0x0(%esi),%esi
 574:	8b 10                	mov    (%eax),%edx
 576:	39 c8                	cmp    %ecx,%eax
 578:	73 04                	jae    57e <free+0x1e>
 57a:	39 d1                	cmp    %edx,%ecx
 57c:	72 12                	jb     590 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 57e:	39 d0                	cmp    %edx,%eax
 580:	72 08                	jb     58a <free+0x2a>
 582:	39 c8                	cmp    %ecx,%eax
 584:	72 0a                	jb     590 <free+0x30>
 586:	39 d1                	cmp    %edx,%ecx
 588:	72 06                	jb     590 <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 58a:	89 d0                	mov    %edx,%eax
 58c:	eb e6                	jmp    574 <free+0x14>
 58e:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 590:	8b 73 fc             	mov    -0x4(%ebx),%esi
 593:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 596:	39 d7                	cmp    %edx,%edi
 598:	74 19                	je     5b3 <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 59a:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 59d:	8b 50 04             	mov    0x4(%eax),%edx
 5a0:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5a3:	39 f1                	cmp    %esi,%ecx
 5a5:	74 23                	je     5ca <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5a7:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5a9:	a3 a8 09 00 00       	mov    %eax,0x9a8
}
 5ae:	5b                   	pop    %ebx
 5af:	5e                   	pop    %esi
 5b0:	5f                   	pop    %edi
 5b1:	5d                   	pop    %ebp
 5b2:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 5b3:	03 72 04             	add    0x4(%edx),%esi
 5b6:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5b9:	8b 10                	mov    (%eax),%edx
 5bb:	8b 12                	mov    (%edx),%edx
 5bd:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 5c0:	8b 50 04             	mov    0x4(%eax),%edx
 5c3:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5c6:	39 f1                	cmp    %esi,%ecx
 5c8:	75 dd                	jne    5a7 <free+0x47>
    p->s.size += bp->s.size;
 5ca:	03 53 fc             	add    -0x4(%ebx),%edx
 5cd:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5d0:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5d3:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 5d5:	a3 a8 09 00 00       	mov    %eax,0x9a8
}
 5da:	5b                   	pop    %ebx
 5db:	5e                   	pop    %esi
 5dc:	5f                   	pop    %edi
 5dd:	5d                   	pop    %ebp
 5de:	c3                   	ret    
 5df:	90                   	nop

000005e0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 5e0:	55                   	push   %ebp
 5e1:	89 e5                	mov    %esp,%ebp
 5e3:	57                   	push   %edi
 5e4:	56                   	push   %esi
 5e5:	53                   	push   %ebx
 5e6:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
 5ec:	83 c3 07             	add    $0x7,%ebx
 5ef:	c1 eb 03             	shr    $0x3,%ebx
 5f2:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 5f3:	8b 0d a8 09 00 00    	mov    0x9a8,%ecx
 5f9:	85 c9                	test   %ecx,%ecx
 5fb:	0f 84 95 00 00 00    	je     696 <malloc+0xb6>
 601:	8b 01                	mov    (%ecx),%eax
 603:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 606:	39 da                	cmp    %ebx,%edx
 608:	73 66                	jae    670 <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 60a:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 611:	eb 0c                	jmp    61f <malloc+0x3f>
 613:	90                   	nop
    }
    if(p == freep)
 614:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 616:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 618:	8b 50 04             	mov    0x4(%eax),%edx
 61b:	39 d3                	cmp    %edx,%ebx
 61d:	76 51                	jbe    670 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 61f:	3b 05 a8 09 00 00    	cmp    0x9a8,%eax
 625:	75 ed                	jne    614 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 627:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 62d:	76 35                	jbe    664 <malloc+0x84>
 62f:	89 f8                	mov    %edi,%eax
 631:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 633:	89 04 24             	mov    %eax,(%esp)
 636:	e8 41 fd ff ff       	call   37c <sbrk>
  if(p == (char*)-1)
 63b:	83 f8 ff             	cmp    $0xffffffff,%eax
 63e:	74 18                	je     658 <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 640:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 643:	83 c0 08             	add    $0x8,%eax
 646:	89 04 24             	mov    %eax,(%esp)
 649:	e8 12 ff ff ff       	call   560 <free>
  return freep;
 64e:	8b 0d a8 09 00 00    	mov    0x9a8,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 654:	85 c9                	test   %ecx,%ecx
 656:	75 be                	jne    616 <malloc+0x36>
        return 0;
 658:	31 c0                	xor    %eax,%eax
  }
}
 65a:	83 c4 1c             	add    $0x1c,%esp
 65d:	5b                   	pop    %ebx
 65e:	5e                   	pop    %esi
 65f:	5f                   	pop    %edi
 660:	5d                   	pop    %ebp
 661:	c3                   	ret    
 662:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 664:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 669:	be 00 10 00 00       	mov    $0x1000,%esi
 66e:	eb c3                	jmp    633 <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 670:	39 d3                	cmp    %edx,%ebx
 672:	74 1c                	je     690 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 674:	29 da                	sub    %ebx,%edx
 676:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 679:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 67c:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 67f:	89 0d a8 09 00 00    	mov    %ecx,0x9a8
      return (void*)(p + 1);
 685:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 688:	83 c4 1c             	add    $0x1c,%esp
 68b:	5b                   	pop    %ebx
 68c:	5e                   	pop    %esi
 68d:	5f                   	pop    %edi
 68e:	5d                   	pop    %ebp
 68f:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 690:	8b 10                	mov    (%eax),%edx
 692:	89 11                	mov    %edx,(%ecx)
 694:	eb e9                	jmp    67f <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 696:	c7 05 a8 09 00 00 ac 	movl   $0x9ac,0x9a8
 69d:	09 00 00 
 6a0:	c7 05 ac 09 00 00 ac 	movl   $0x9ac,0x9ac
 6a7:	09 00 00 
    base.s.size = 0;
 6aa:	c7 05 b0 09 00 00 00 	movl   $0x0,0x9b0
 6b1:	00 00 00 
 6b4:	b8 ac 09 00 00       	mov    $0x9ac,%eax
 6b9:	e9 4c ff ff ff       	jmp    60a <malloc+0x2a>

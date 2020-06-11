
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
  16:	be d9 06 00 00       	mov    $0x6d9,%esi
  1b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  20:	89 df                	mov    %ebx,%edi
  22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  char data[512];

  printf(1, "stressfs starting\n");
  24:	c7 44 24 04 b6 06 00 	movl   $0x6b6,0x4(%esp)
  2b:	00 
  2c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  33:	e8 ec 03 00 00       	call   424 <printf>
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
  6f:	c7 44 24 04 c9 06 00 	movl   $0x6c9,0x4(%esp)
  76:	00 
  77:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7e:	88 44 24 18          	mov    %al,0x18(%esp)
  82:	e8 9d 03 00 00       	call   424 <printf>

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
  d3:	c7 44 24 04 d3 06 00 	movl   $0x6d3,0x4(%esp)
  da:	00 
  db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e2:	e8 3d 03 00 00       	call   424 <printf>

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

00000394 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 394:	55                   	push   %ebp
 395:	89 e5                	mov    %esp,%ebp
 397:	83 ec 28             	sub    $0x28,%esp
 39a:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 39d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3a4:	00 
 3a5:	8d 55 f4             	lea    -0xc(%ebp),%edx
 3a8:	89 54 24 04          	mov    %edx,0x4(%esp)
 3ac:	89 04 24             	mov    %eax,(%esp)
 3af:	e8 60 ff ff ff       	call   314 <write>
}
 3b4:	c9                   	leave  
 3b5:	c3                   	ret    
 3b6:	66 90                	xchg   %ax,%ax

000003b8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b8:	55                   	push   %ebp
 3b9:	89 e5                	mov    %esp,%ebp
 3bb:	57                   	push   %edi
 3bc:	56                   	push   %esi
 3bd:	53                   	push   %ebx
 3be:	83 ec 1c             	sub    $0x1c,%esp
 3c1:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 3c3:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
 3c8:	85 db                	test   %ebx,%ebx
 3ca:	74 04                	je     3d0 <printint+0x18>
 3cc:	85 d2                	test   %edx,%edx
 3ce:	78 4a                	js     41a <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3d0:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3d2:	31 db                	xor    %ebx,%ebx
 3d4:	eb 04                	jmp    3da <printint+0x22>
 3d6:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 3d8:	89 d3                	mov    %edx,%ebx
 3da:	31 d2                	xor    %edx,%edx
 3dc:	f7 f1                	div    %ecx
 3de:	8a 92 ea 06 00 00    	mov    0x6ea(%edx),%dl
 3e4:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 3e8:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 3eb:	85 c0                	test   %eax,%eax
 3ed:	75 e9                	jne    3d8 <printint+0x20>
  if(neg)
 3ef:	85 ff                	test   %edi,%edi
 3f1:	74 08                	je     3fb <printint+0x43>
    buf[i++] = '-';
 3f3:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 3f8:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 3fb:	8d 5a ff             	lea    -0x1(%edx),%ebx
 3fe:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 400:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 405:	89 f0                	mov    %esi,%eax
 407:	e8 88 ff ff ff       	call   394 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 40c:	4b                   	dec    %ebx
 40d:	83 fb ff             	cmp    $0xffffffff,%ebx
 410:	75 ee                	jne    400 <printint+0x48>
    putc(fd, buf[i]);
}
 412:	83 c4 1c             	add    $0x1c,%esp
 415:	5b                   	pop    %ebx
 416:	5e                   	pop    %esi
 417:	5f                   	pop    %edi
 418:	5d                   	pop    %ebp
 419:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 41a:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 41c:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 421:	eb af                	jmp    3d2 <printint+0x1a>
 423:	90                   	nop

00000424 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 424:	55                   	push   %ebp
 425:	89 e5                	mov    %esp,%ebp
 427:	57                   	push   %edi
 428:	56                   	push   %esi
 429:	53                   	push   %ebx
 42a:	83 ec 2c             	sub    $0x2c,%esp
 42d:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 430:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 433:	8a 0b                	mov    (%ebx),%cl
 435:	84 c9                	test   %cl,%cl
 437:	74 7b                	je     4b4 <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 439:	8d 45 10             	lea    0x10(%ebp),%eax
 43c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 43f:	31 f6                	xor    %esi,%esi
 441:	eb 17                	jmp    45a <printf+0x36>
 443:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 444:	83 f9 25             	cmp    $0x25,%ecx
 447:	74 73                	je     4bc <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 449:	0f be d1             	movsbl %cl,%edx
 44c:	89 f8                	mov    %edi,%eax
 44e:	e8 41 ff ff ff       	call   394 <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 453:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 454:	8a 0b                	mov    (%ebx),%cl
 456:	84 c9                	test   %cl,%cl
 458:	74 5a                	je     4b4 <printf+0x90>
    c = fmt[i] & 0xff;
 45a:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 45d:	85 f6                	test   %esi,%esi
 45f:	74 e3                	je     444 <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 461:	83 fe 25             	cmp    $0x25,%esi
 464:	75 ed                	jne    453 <printf+0x2f>
      if(c == 'd'){
 466:	83 f9 64             	cmp    $0x64,%ecx
 469:	0f 84 c1 00 00 00    	je     530 <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 46f:	83 f9 78             	cmp    $0x78,%ecx
 472:	74 50                	je     4c4 <printf+0xa0>
 474:	83 f9 70             	cmp    $0x70,%ecx
 477:	74 4b                	je     4c4 <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 479:	83 f9 73             	cmp    $0x73,%ecx
 47c:	74 6a                	je     4e8 <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 47e:	83 f9 63             	cmp    $0x63,%ecx
 481:	0f 84 91 00 00 00    	je     518 <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 487:	ba 25 00 00 00       	mov    $0x25,%edx
 48c:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 48e:	83 f9 25             	cmp    $0x25,%ecx
 491:	74 10                	je     4a3 <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 493:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 496:	e8 f9 fe ff ff       	call   394 <putc>
        putc(fd, c);
 49b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 49e:	0f be d1             	movsbl %cl,%edx
 4a1:	89 f8                	mov    %edi,%eax
 4a3:	e8 ec fe ff ff       	call   394 <putc>
      }
      state = 0;
 4a8:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 4aa:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 4ab:	8a 0b                	mov    (%ebx),%cl
 4ad:	84 c9                	test   %cl,%cl
 4af:	75 a9                	jne    45a <printf+0x36>
 4b1:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 4b4:	83 c4 2c             	add    $0x2c,%esp
 4b7:	5b                   	pop    %ebx
 4b8:	5e                   	pop    %esi
 4b9:	5f                   	pop    %edi
 4ba:	5d                   	pop    %ebp
 4bb:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 4bc:	be 25 00 00 00       	mov    $0x25,%esi
 4c1:	eb 90                	jmp    453 <printf+0x2f>
 4c3:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 4c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 4cb:	b9 10 00 00 00       	mov    $0x10,%ecx
 4d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4d3:	8b 10                	mov    (%eax),%edx
 4d5:	89 f8                	mov    %edi,%eax
 4d7:	e8 dc fe ff ff       	call   3b8 <printint>
        ap++;
 4dc:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4e0:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 4e2:	e9 6c ff ff ff       	jmp    453 <printf+0x2f>
 4e7:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 4e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4eb:	8b 30                	mov    (%eax),%esi
        ap++;
 4ed:	83 c0 04             	add    $0x4,%eax
 4f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4f3:	85 f6                	test   %esi,%esi
 4f5:	74 5a                	je     551 <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 4f7:	8a 16                	mov    (%esi),%dl
 4f9:	84 d2                	test   %dl,%dl
 4fb:	74 14                	je     511 <printf+0xed>
 4fd:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 500:	0f be d2             	movsbl %dl,%edx
 503:	89 f8                	mov    %edi,%eax
 505:	e8 8a fe ff ff       	call   394 <putc>
          s++;
 50a:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 50b:	8a 16                	mov    (%esi),%dl
 50d:	84 d2                	test   %dl,%dl
 50f:	75 ef                	jne    500 <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 511:	31 f6                	xor    %esi,%esi
 513:	e9 3b ff ff ff       	jmp    453 <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 518:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 51b:	0f be 10             	movsbl (%eax),%edx
 51e:	89 f8                	mov    %edi,%eax
 520:	e8 6f fe ff ff       	call   394 <putc>
        ap++;
 525:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 529:	31 f6                	xor    %esi,%esi
 52b:	e9 23 ff ff ff       	jmp    453 <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 530:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 537:	b1 0a                	mov    $0xa,%cl
 539:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 53c:	8b 10                	mov    (%eax),%edx
 53e:	89 f8                	mov    %edi,%eax
 540:	e8 73 fe ff ff       	call   3b8 <printint>
        ap++;
 545:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 549:	66 31 f6             	xor    %si,%si
 54c:	e9 02 ff ff ff       	jmp    453 <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 551:	be e3 06 00 00       	mov    $0x6e3,%esi
 556:	eb 9f                	jmp    4f7 <printf+0xd3>

00000558 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 558:	55                   	push   %ebp
 559:	89 e5                	mov    %esp,%ebp
 55b:	57                   	push   %edi
 55c:	56                   	push   %esi
 55d:	53                   	push   %ebx
 55e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 561:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 564:	a1 a0 09 00 00       	mov    0x9a0,%eax
 569:	8d 76 00             	lea    0x0(%esi),%esi
 56c:	8b 10                	mov    (%eax),%edx
 56e:	39 c8                	cmp    %ecx,%eax
 570:	73 04                	jae    576 <free+0x1e>
 572:	39 d1                	cmp    %edx,%ecx
 574:	72 12                	jb     588 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 576:	39 d0                	cmp    %edx,%eax
 578:	72 08                	jb     582 <free+0x2a>
 57a:	39 c8                	cmp    %ecx,%eax
 57c:	72 0a                	jb     588 <free+0x30>
 57e:	39 d1                	cmp    %edx,%ecx
 580:	72 06                	jb     588 <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 582:	89 d0                	mov    %edx,%eax
 584:	eb e6                	jmp    56c <free+0x14>
 586:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 588:	8b 73 fc             	mov    -0x4(%ebx),%esi
 58b:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 58e:	39 d7                	cmp    %edx,%edi
 590:	74 19                	je     5ab <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 592:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 595:	8b 50 04             	mov    0x4(%eax),%edx
 598:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 59b:	39 f1                	cmp    %esi,%ecx
 59d:	74 23                	je     5c2 <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 59f:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5a1:	a3 a0 09 00 00       	mov    %eax,0x9a0
}
 5a6:	5b                   	pop    %ebx
 5a7:	5e                   	pop    %esi
 5a8:	5f                   	pop    %edi
 5a9:	5d                   	pop    %ebp
 5aa:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 5ab:	03 72 04             	add    0x4(%edx),%esi
 5ae:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5b1:	8b 10                	mov    (%eax),%edx
 5b3:	8b 12                	mov    (%edx),%edx
 5b5:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 5b8:	8b 50 04             	mov    0x4(%eax),%edx
 5bb:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5be:	39 f1                	cmp    %esi,%ecx
 5c0:	75 dd                	jne    59f <free+0x47>
    p->s.size += bp->s.size;
 5c2:	03 53 fc             	add    -0x4(%ebx),%edx
 5c5:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5c8:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5cb:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 5cd:	a3 a0 09 00 00       	mov    %eax,0x9a0
}
 5d2:	5b                   	pop    %ebx
 5d3:	5e                   	pop    %esi
 5d4:	5f                   	pop    %edi
 5d5:	5d                   	pop    %ebp
 5d6:	c3                   	ret    
 5d7:	90                   	nop

000005d8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 5d8:	55                   	push   %ebp
 5d9:	89 e5                	mov    %esp,%ebp
 5db:	57                   	push   %edi
 5dc:	56                   	push   %esi
 5dd:	53                   	push   %ebx
 5de:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
 5e4:	83 c3 07             	add    $0x7,%ebx
 5e7:	c1 eb 03             	shr    $0x3,%ebx
 5ea:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 5eb:	8b 0d a0 09 00 00    	mov    0x9a0,%ecx
 5f1:	85 c9                	test   %ecx,%ecx
 5f3:	0f 84 95 00 00 00    	je     68e <malloc+0xb6>
 5f9:	8b 01                	mov    (%ecx),%eax
 5fb:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 5fe:	39 da                	cmp    %ebx,%edx
 600:	73 66                	jae    668 <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 602:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 609:	eb 0c                	jmp    617 <malloc+0x3f>
 60b:	90                   	nop
    }
    if(p == freep)
 60c:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 60e:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 610:	8b 50 04             	mov    0x4(%eax),%edx
 613:	39 d3                	cmp    %edx,%ebx
 615:	76 51                	jbe    668 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 617:	3b 05 a0 09 00 00    	cmp    0x9a0,%eax
 61d:	75 ed                	jne    60c <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 61f:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 625:	76 35                	jbe    65c <malloc+0x84>
 627:	89 f8                	mov    %edi,%eax
 629:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 62b:	89 04 24             	mov    %eax,(%esp)
 62e:	e8 49 fd ff ff       	call   37c <sbrk>
  if(p == (char*)-1)
 633:	83 f8 ff             	cmp    $0xffffffff,%eax
 636:	74 18                	je     650 <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 638:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 63b:	83 c0 08             	add    $0x8,%eax
 63e:	89 04 24             	mov    %eax,(%esp)
 641:	e8 12 ff ff ff       	call   558 <free>
  return freep;
 646:	8b 0d a0 09 00 00    	mov    0x9a0,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 64c:	85 c9                	test   %ecx,%ecx
 64e:	75 be                	jne    60e <malloc+0x36>
        return 0;
 650:	31 c0                	xor    %eax,%eax
  }
}
 652:	83 c4 1c             	add    $0x1c,%esp
 655:	5b                   	pop    %ebx
 656:	5e                   	pop    %esi
 657:	5f                   	pop    %edi
 658:	5d                   	pop    %ebp
 659:	c3                   	ret    
 65a:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 65c:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 661:	be 00 10 00 00       	mov    $0x1000,%esi
 666:	eb c3                	jmp    62b <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 668:	39 d3                	cmp    %edx,%ebx
 66a:	74 1c                	je     688 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 66c:	29 da                	sub    %ebx,%edx
 66e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 671:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 674:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 677:	89 0d a0 09 00 00    	mov    %ecx,0x9a0
      return (void*)(p + 1);
 67d:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 680:	83 c4 1c             	add    $0x1c,%esp
 683:	5b                   	pop    %ebx
 684:	5e                   	pop    %esi
 685:	5f                   	pop    %edi
 686:	5d                   	pop    %ebp
 687:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 688:	8b 10                	mov    (%eax),%edx
 68a:	89 11                	mov    %edx,(%ecx)
 68c:	eb e9                	jmp    677 <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 68e:	c7 05 a0 09 00 00 a4 	movl   $0x9a4,0x9a0
 695:	09 00 00 
 698:	c7 05 a4 09 00 00 a4 	movl   $0x9a4,0x9a4
 69f:	09 00 00 
    base.s.size = 0;
 6a2:	c7 05 a8 09 00 00 00 	movl   $0x0,0x9a8
 6a9:	00 00 00 
 6ac:	b8 a4 09 00 00       	mov    $0x9a4,%eax
 6b1:	e9 4c ff ff ff       	jmp    602 <malloc+0x2a>

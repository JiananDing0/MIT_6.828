## Exercise 4
* In order to solve this problem, we should first create a ```Makefile``` with the basic c++ command ```gcc pointers.c -o pointers```in order to compile the *pointer.c* file.
* After it compiles, we can directly execute the file by execute ```./pointers"``` and the following content shows up:
```
1: a = 0x7ffee62f18a0, b = 0x7ff560405860, c = 0x7ffee62f1908
2: a[0] = 200, a[1] = 101, a[2] = 102, a[3] = 103
3: a[0] = 200, a[1] = 300, a[2] = 301, a[3] = 302
4: a[0] = 200, a[1] = 400, a[2] = 301, a[3] = 302
5: a[0] = 200, a[1] = 128144, a[2] = 256, a[3] = 302
6: a = 0x7ffee62f18a0, b = 0x7ffee62f18a4, c = 0x7ffee62f18a1
```

#### 1. Initialization:
```
int a[4];
int *b = malloc(16);
int *c;
int i;
```
In this part, we can easily observe that variable ```a``` and variable ```b``` should correspond to the same amount of memory occupation: 16 bytes, which is 128 bits; variable ```c``` is an unintialized pointer. In addition, both ```a``` and ```c``` should be stored in stack as local variables, ```b``` should be stored in heap.

#### 2. Code corresponds to the first printing statement is:
```
printf("1: a = %p, b = %p, c = %p\n", a, b, c);
```
which results in:
```
1: a = 0x7ffee62f18a0, b = 0x7ff560405860, c = 0x7ffee62f1908
```
In this part, we can observe ```c - a``` is 0x68

#### 3. Code corresponds to the second printing statement is:
```
c = a;
for (i = 0; i < 4; i++)
    a[i] = 100 + i;
c[0] = 200;
printf("2: a[0] = %d, a[1] = %d, a[2] = %d, a[3] = %d\n", a[0], a[1], a[2], a[3]);
```
which results in:
```
2: a[0] = 200, a[1] = 101, a[2] = 102, a[3] = 103
```
This part seems to be normal. ```c=a```result in c and a point to a same array sturcture. As a result, we can directly change value in array ```a``` by using ```c[i] = n```

#### 4. Code corresponds to the third printing statement is:
```
c[1] = 300;
*(c + 2) = 301;
3[c] = 302;
printf("3: a[0] = %d, a[1] = %d, a[2] = %d, a[3] = %d\n", a[0], a[1], a[2], a[3]);
```
which results in:
```
3: a[0] = 200, a[1] = 300, a[2] = 301, a[3] = 302
```
This part provide some useful application of pointer: 
* ```c[i]```is the same as ```i[c]```
* Pointer can be increamented in the unit of its data type. For example```c + 2``` result in increament of 8 because c is an integer pointer.

#### 5. Code corresponds to the forth printing statement is:
```
c = c + 1;
*c = 400;
printf("4: a[0] = %d, a[1] = %d, a[2] = %d, a[3] = %d\n", a[0], a[1], a[2], a[3]);
```
which results in:
```
4: a[0] = 200, a[1] = 400, a[2] = 301, a[3] = 302
```
Here, variable c is regarded as an integer pointer. As a result, c + 1 result in an incremental of 4 on its value.

#### 6. Code corresponds to the fifth printing statement is:
```
c = (int *) ((char *) c + 1);
*c = 500;
printf("5: a[0] = %d, a[1] = %d, a[2] = %d, a[3] = %d\n", a[0], a[1], a[2], a[3]);
```
which results in:
```
5: a[0] = 200, a[1] = 128144, a[2] = 256, a[3] = 302
```
In this case, variable ```c``` is incremented by 1 instead of 4. So it overwrite both ```a[1]``` and ```a[2]```: (Assume storage of integer in **little endien** is more reasonable in comparison to big endien)
1. Before write: 
   * Original value at ```a[1]```, 400, can be represented as the 0x190, which is the following:
```
    --------------------------------------- 
   |1001|0000|0000|0001|0000|0000|0000|0000|  
    --------------------------------------- 
```
   * Original value at ```a[2]```, 301, can be represented as the 0x12D, which is the following:
```
    ---------------------------------------
   |0010|1101|0000|0001|0000|0000|0000|0000|
    ---------------------------------------
```
2. On writing:
   * c is incremented by 1, which corresponds to 8 bits. Now it points to:
```
    ---------------------------------------  
   |1001|0000^0000|0001|0000|0000|0000|0000|
    ---------------------------------------
```
   * The value ```500``` can be written in 0x1F4, which corresponds to:
```
    ---------------------------------------
   |1111|0100|0000|0001|0000|0000|0000|0000|
    ---------------------------------------
```
   * Now we are trying to overwrite the number at the following place:
```
              ---------------------------------------
             |1111|0100|0000|0001|0000|0000|0000|0000|
              ---------------------------------------
    --------------------------------------- ---------------------------------------  
   |1001|0000|0000|0001|0000|0000|0000|0000|0010|1101|0000|0001|0000|0000|0000|0000|  
    --------------------------------------- ---------------------------------------
```
3. After write:
   According to the analysis above, we result in:
```
    --------------------------------------- ---------------------------------------
   |1001|0000|1111|0100|0000|0001|0000|0000|0000|0000|0000|0001|0000|0000|0000|0000|
    --------------------------------------- ---------------------------------------
```
   This can be writen as: ```0x0001F490``` and ```0x00000100```. As we know, the value ```128144``` can be written as ```0x1F490``` in hexadecimal. Correspondingly, the value ```256``` can be written as ```0x100``` in hex.
   
#### 7. Code corresponds to the sixth printing statement is:
```
b = (int *) a + 1;
c = (int *) ((char *) a + 1);
printf("6: a = %p, b = %p, c = %p\n", a, b, c);
```
which results in:
```
6: a = 0x7ffee62f18a0, b = 0x7ffee62f18a4, c = 0x7ffee62f18a1
```
No explanations required here. Similar to above.

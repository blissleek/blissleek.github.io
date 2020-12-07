---
title: Java 8 流式操作API Stream
date: 2020-12-06 00:19:47
tags:
- Stream
categories:
- Java
---

`Classes to support functional-style operations on streams of elements` 这是 oracle 官方对 `Package java.util.stream`包的解释，可以了解 Stream 包是对元素流的函数式操作进行支持。Stream API 是 Java8 中处理集合的关键抽象概念，可以让我们以一种类 SQL 语句从数据库查询数据的方式对集合进行操作，极大的简化了 Java 对集合处理数据的方式。

<!-- more -->

**Stream 和集合不同：**

- 流不是存储元素的数据结构，没有存储空间。即对流的操作会产生结果，但不会修改其源。
- 惰性求值，许多流在中间处理过程中，只是对操作进行了记录，并不会立即执行，需要等到执行终止操作的时候才会进行实际的计算。
- Stream 流是一种消耗品，在流的生存期内，流的元素只能访问一次。例子如下：
```java
String[] strings = {"java", "Stream", "Api", "Java8"};
Stream<String> stream = Arrays.stream(strings);
stream.forEach(System.out::print);
System.out.println();
stream.forEach(System.out::print);
```

如上面的语句在执行到第二句 `stream.forEach(System.out::print)` 的时候会抛出异常

```java
javaStreamApiJava8
Exception in thread "main" java.lang.IllegalStateException: stream has already been operated upon or closed
```

### Stream 操作分类

<img src="https://tva1.sinaimg.cn/large/0081Kckwgy1glfqi55wyhj31110phmz5.jpg" style="zoom: 70%;" />

无状态：指元素的处理不受之前元素的影响。

有状态：指该操作只有拿到所有元素之后才能继续下去。

非短路操作：指必须处理所有元素才能得到最终结果。

短路操作：指遇到某些符合条件的元素就可以得到最终结果，如 A || B，只要A为true，则无需判断B的结果。

> 我们也可以将中间操作称为懒操作。

### 流的创建

- 使用Collection下的 stream() 和 parallelStream() 方法

```java
List<String> strings = new ArrayList<>();
Stream<String> stream = strings.stream();
Stream<String> parallelStream = strings.parallelStream();
```

- 使用Arrays 中的静态方法 stream() ，将数组转成流

```java
Integer[] nums = new Integer[10];
Stream<Integer> stream = Arrays.stream(nums);
```

- 使用Stream中的静态方法：of()、iterate()、generate()

```java
String[] strings = new String[] {"java8","Stream","API","operation"};
Stream<String> stream1 = Stream.of(strings);

Stream<Integer> stream2 = Stream.iterate(1, i -> i + 1).limit(5);
stream2.forEach(System.out::println);  // 1 2 3 4 5

Stream<Double> stream3 = Stream.generate(Math::random).limit(5);
```

### 流的中间操作

| 操作       | 作用                                                         |
| ---------- | ------------------------------------------------------------ |
| filter()   | 过滤流，过滤流中的元素，返回一个符合条件的Stream             |
| map()      | 转换流，将给定函数应用于该流的元素的结果转换为另外一种流（mapToInt、mapToLong、mapToDouble 返回int、long、double基本类型对应的 IntStream、LongStream、DoubleStream流） |
| flatMap()  | 能够展平"包裹的流"，简单的说，就是合并一个或多个流成为一个新流（flatMapToInt、flatMapToLong、flatMapToDouble 返回对应的 IntStream、LongStream、DoubleStream流） |
| peek()     | 查看流中元素的数据状态                                       |
| distinct() | 返回去重的 Stream                                            |
| sorted()   | 返回一个排序的 Stream                                        |
| limit()    | 返回前n个元素数据组成的 Stream                               |
| skip()     | 返回第n个元素后面数据组成的 Stream，类似 mysql 中的 offset，配合 limit() 可实现分页操作 |

- filter()

```java
 List<String> strings = Arrays.asList("java8","Stream","API","operation");
 List<String> list = strings.stream()
   			.filter(str -> str.length() == 5)
   			.collect(Collectors.toList());
System.out.println(list); 
/* [java8] */
```

- map()

```java
List<String> strings = Arrays.asList("java8","Stream","API","operation");
List<String> list = strings.stream()
  			.map(str -> str + "map")
  			.collect(Collectors.toList());
System.out.println(list);
/* [java8map, Streammap, APImap, operationmap] */
```

- flatMap()

```java

```

- peek()

```java

```

- distinct()、sorted()、limit()、skip()

```java
 List<String> strings = Arrays.asList("java8","Stream","API","operation","java8","API","limit");
 List<String> list = strings.stream()
          .filter(str -> str.length() > 3) // [java8, Stream, operation, java8, limit]
          .distinct() // [java8, Stream, operation, limit]
          .sorted() // [Stream, java8, limit, operation]
          .sorted((s1,s2) -> s2.compareTo(s1)) // [operation, limit, java8, Stream]
          .skip(1) // [limit, java8, Stream]
          .limit(2) // [limit, java8]
          .collect(Collectors.toList());
 System.out.println(list); // [limit, java8]
```


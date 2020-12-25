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



## Stream 操作分类

<img src="https://tva1.sinaimg.cn/large/0081Kckwgy1glfqi55wyhj31110phmz5.jpg" style="zoom: 70%;" />

无状态：指元素的处理不受之前元素的影响。

有状态：指该操作只有拿到所有元素之后才能继续下去。

非短路操作：指必须处理所有元素才能得到最终结果。

短路操作：指遇到某些符合条件的元素就可以得到最终结果，如 A || B，只要A为true，则无需判断B的结果。

> 我们也可以将中间操作称为懒操作。



## 流的创建

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



## 流的中间操作

| 操作       | 作用                                                         |
| ---------- | ------------------------------------------------------------ |
| filter()   | 过滤流，过滤流中的元素，返回一个符合条件的Stream             |
| map()      | 转换流，将给定函数应用于该流的元素的结果转换为另外一种流（mapToInt、mapToLong、mapToDouble 返回int、long、double基本类型对应的 IntStream、LongStream、DoubleStream流） |
| flatMap()  | 能够展平"包裹的流"，简单的说，就是合并一个或多个流成为一个新流（flatMapToInt、flatMapToLong、flatMapToDouble 返回对应的 IntStream、LongStream、DoubleStream流） |
| peek()     | 如同于map，能得到流中的每一个元素。但map接收的是一个Function表达式，有返回值；而peek接收的是Consumer表达式，没有返回值。（查看流中元素的数据状态） |
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
List<String> list = Arrays.asList("a,b,c", "1,2,3");
list.stream()
  .map(s -> s.replaceAll(",", ""))
  .forEach(s -> System.out.print(s+ " "));
System.out.println();
list.stream()
  .flatMap(s -> Arrays.stream(s.split(","))) // 将每个元素转化成一个流
  .forEach(s -> System.out.print(s+ " "));
/* 
abc 123 
a b c 1 2 3 
*/
```

- peek() 

```java
// JDK 内置示例
Stream.of("one", "two", "three", "four")
   			.filter(e -> e.length() > 3)
		    .peek(e -> System.out.println("Filtered value: " + e))
 		    .map(String::toUpperCase)
		    .peek(e -> System.out.println("Mapped value: " + e))
 		    .collect(Collectors.toList());
/* 输出结果
Filtered value: three
Mapped value: THREE
Filtered value: four
Mapped value: FOUR
*/

// 反例
Stream.of("one", "two", "three", "four")
   			.filter(e -> e.length() > 3)
		    .peek(e -> System.out.println("Filtered value: " + e))
 		    .peek(String::toUpperCase)
		    .peek(e -> System.out.println("Mapped value: " + e))
 		    .collect(Collectors.toList());
/*
Filtered value: three
Mapped value: three
Filtered value: four
Mapped value: four
*/
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



## 流的终止操作

| 操作                    | 作用                                                         |
| ----------------------- | ------------------------------------------------------------ |
| forEach()               | 循环操作Stream中数据                                         |
| toArray()               | 返回流中元素对应的数组对象                                   |
| reduce()                | 聚合操作，用来做统计，将流中元素反复结合起来统计计算，得到一个值 |
| collect()               | 聚合操作，封装目标数据，将流转换为其他形式接收，如： List、Set、Map、Array |
| min()、max()、count()   | 聚合操作，最小值，最大值，总数量                             |
| anyMatch()              | 短路操作，有一个符合条件返回true                             |
| allMatch()、noneMatch() | 所有数据都符合条件返回true；所有数据都不符合条件返回true     |
| findFirst()、findAny()  | 短路操作，获取第一个元素；短路操作，获取任一元素             |
| forEachOrdered()        | 按元素顺序执行循环操作(与foreach 的区别主要在并行处理上，)   |

- toArray()

```java
List<String> list = Arrays.asList("a,b,c", "1,2,3");
String[] array = list.stream()
        .map(s -> s.replaceAll(",", ""))
        .toArray(String[]::new);
System.out.println(Arrays.toString(array));
// [abc, 123]
```

- min()、max()、count()

```java
List<Integer> nums = Arrays.asList(1,2,3,4,5,6,7);
long count1 = nums.stream().count();
long count2 = nums.stream().collect(Collectors.counting());
Integer max = nums.stream().max(Integer::compareTo).get();
Integer min = nums.stream().min(Integer::compareTo).get();
System.out.println(count1 + " " + count2 + " " + max+ " " + min);
// 7 7 7 1
```

- anyMatch()、allMatch()、noneMatch()

```java
List<Integer> list = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9);

boolean allMatch = list.stream().allMatch(i -> i > 6);
boolean noneMatch = list.stream().noneMatch(i -> i > 10);
boolean anyMatch = list.stream().anyMatch(i -> i > 4);
System.out.println(allMatch + " " + noneMatch +  " " + anyMatch);
// false true true
```

- findFirst()、findAny()

```java
List<String> strings = Arrays.asList("java8","Stream","API","operation","java8","API","limit");
Optional<String> first1 = strings.stream()
        .filter("java8"::equals)
        .findFirst();
System.out.println(first1.orElse(null));

Optional<String> first2 = strings.stream()
        .filter("java8_2"::equals)
        .findFirst();
System.out.println(first2.orElse(null));

Optional<String> any = strings.stream()
        .filter("API"::equals)
        .findAny();
System.out.println(any.orElse(null));
/*
java8
null
API */
```

- forEach()、forEachOrdered()

```java
Stream.of("AAA","BBB","CCC").parallel().forEach(s->System.out.println("forEach:"+s));
Stream.of("AAA","BBB","CCC").parallel().forEachOrdered(s->System.out.println("forEachOrdered:"+s));
/**
* forEach() 输出不稳定，forEachOrdered()输出稳定，以为所有元素按顺序执行操作
  forEach:AAA
  forEach:CCC
  forEach:BBB
  forEachOrdered:AAA
  forEachOrdered:BBB
  forEachOrdered:CCC
*/
/*
forEach:AAA
forEach:BBB
forEach:CCC
forEachOrdered:AAA
forEachOrdered:BBB
forEachOrdered:CCC
*/
```



## 规约操作

{% note success  %}

 Optional<T> reduce(BinaryOperator<T> accumulator)：第一次执行时，accumulator函数的第一个参数为流中的第一个元素，第二个参数为流中元素的第二个元素；第二次执行时，第一个参数为第一次函数执行的结果，第二个参数为流中的第三个元素；依次类推。

{% endnote %}

{% note success  %}

T reduce(T identity, BinaryOperator<T> accumulator)：流程跟上面一样，只是第一次执行时，accumulator函数的第一个参数为identity，而第二个参数为流中的第一个元素。

{% endnote %}

{% note success  %}

<U> U reduce(U identity,BiFunction<U, ? super T, U> accumulator,BinaryOperator<U> combiner)：在串行流(stream)中，该方法跟第二个方法一样，即第三个参数combiner不会起作用。在并行流(parallelStream)中,我们知道流被fork join出多个线程进行执行，此时每个线程的执行流程就跟第二个方法reduce(identity,accumulator)一样，而第三个参数combiner函数，则是将每个线程的执行结果当成一个新的流，然后使用第一个方法reduce(accumulator)流程进行规约。

{% endnote %}

```java
T reduce(T identity, BinaryOperator<T> accumulator);

Optional<T> reduce(BinaryOperator<T> accumulator);

<U> U reduce(U identity,
                 BiFunction<U, ? super T, U> accumulator,
                 BinaryOperator<U> combiner);
```

```java
IntStream.range(1, 5).forEach(i -> System.out.print(i + " "));
System.out.println();
int sum = IntStream.range(1, 5)
  .reduce((x, y) -> x + y)
  .orElse(0);
System.out.println(sum);

int sum2 = IntStream.range(1, 5)
  .reduce(0, (x, y) -> x + 2 * y);
System.out.println(sum2);

int sum3 = IntStream.range(1, 5)
  .reduce(0, Integer::sum);
System.out.println(sum3);
/*
1 2 3 4 
10
20
10
*/
```



## 收集操作





### 参考资料

- [java.util.stream (Java Platform SE 8 )](https://docs.oracle.com/javase/8/docs/api/java/util/stream/package-summary.html)

- [Java 8 stream的详细用法](https://blog.csdn.net/y_k_y/article/details/84633001)

- [欧阳思海](https://blog.ouyangsihai.cn/) . [Java8 的 Stream 流式操作之王者归来](http://blog.ouyangsihai.cn/java8-de-stream-liu-shi-cao-zuo-zhi-wang-zhe-gui-lai.html)



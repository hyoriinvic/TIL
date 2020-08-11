#5장 데이터 조작(데이터 처리 및 가공)
data(iris)

#SQL을 사용한 데이터 처리
install.packages("sqldf")
library(sqldf)
sqldf("select distinct Species from iris")
sqldf("select avg("Sepal_Length") from iris where Species = "setosa"")
sqldf("select species, avg("Sepal_Length") from iris group by species")

#분할, 적용, 재조합을 통한 데이터 분석
install.packages("plyr")
library(plyr)

#adply(): 배열을 받아 데이터프레임을 반환
adply(iris, 1, 
      function(row){
        row$Sepal.Length >= 5.0 & row$Species == "setosa"})
adply(iris, 1,
      function(row){
        data.frame(sepal_ge_5_setosa = c(row$Sepal.Length >= 5.0 &
                                           row$Species == "setosa"))})

#ddply(): 데이터프레임을 입력 받아 데이터프레임을 반환
ddply(iris, .(Species),
      function(sub){
        data.frame(sepal.width.mean = mean(sub$Sepal.Width)})})

#그룹별 연산 쉽게 수행하기 > 자주 사용하는 함수
#baseball 데이터 사용

#transform(): 연산 결과를 데이터프레인의 새로운 컬럼에 저장
head(ddply(baseball, .(id), transform, cyear = year - min(year) + 1))
#mutate(): 여러 컬럼 추가 시, 앞서 추가한 컬럼을 뒤에 추가한 컬럼에서 참조 가능
head(ddply(baseball, .(id), mutate,
           cyear = year - min(year) + 1,
           log_cyear = log(cyear)))
#summarize(): 데이터의 요약 정보 - 결과만을 담은 새로운 데이터프레임 반환
head(ddply(baseball, .(id), summarize, minyear = min(year)))
head(ddply(baseball, .(id), summarize, minyear = min(year), maxyear = max(year)))
#subset(): 각 분할별로 데이터 추출
head(ddply(baseball, .(id), subset, g == max(g)))

#m{adl_}ply(): 데이터프레임 또는 배열을 인자로 받아 각 컬럼을 주어진 함수에 적용, 그 실행 결과를 조합
#mdply()
(x <- data.frame(mean = 1:5, sd = 1:5))
mdply(x, rnorm, n = 2)

#데이터 구조의 변형과 요약
install.packages("reshape2")
library(reshape2)
#french_fries 데이터 사용

#melt(): 식별자, 측정변수, 측정치의 형태로 데이터를 재구성하는 함수
help(melt)
m <- melt(french_fries, id.vars = 1:4)
head(m)
#여러 컬럼으로 나열된 측정치들을 variable, value의 두 개 컬럼을 사용해 여러 행으로 변환

#cast(): melt()된 데이터 측정치를 컬럼으로 나열한 데이터프레임으로 변환
r <- dcast(m, time + treatement + subject + rep ~ ....)
rownames(r) <- NULL #행 번호 무시
rownames(french_fries) <- NULL #행 번호 무시 
identical(r, french_fries) #두 데이터가 완전히 동일함을 확인
#cast()는 데이터를 요약하는 기능도 있음 - melt()에서 사용한 것보다 적은 개수의 식별자를 dcast() formula에 지정
dcast(m, time ~ variable, mean, na.rm = TRUE)
dcast(m, time ~ treatement + variable, mean, na.rm = TRUE)

#데이터 테이블
install.packages("data.table")
library(data.table)

(iris_table <- as.data.table(iris)) #iris 데이터를 데이터 테이블로 변환
tables() #데이터 테이블의 목록 반환

#데이터 테이블의 데이터 접근 방식: [행, 표현식, 옵션]
#행: 행 번호 또는 진릿값
#열: 컬럼 명 또는 표현식
#옵션 by(그룹화)

#key를 사용한 빠른 데이터 접근
DF <- data.frame(x = runif(260000), y = rep(LETTERS, each = 10000))
str(DF)
DT <- as.data.table(DF) #데이터 테이블로 변환
setkey(DT, y) #색인 생성
DT[J("C"), mean(x)] #색인을 사용한 검색 J()

#key를 사용한 데이터 테이블 병합

#참조를 사용한 데이터 수정

#rbindlist(): 리스트를 데이터 테이블로 변환
system.time(x <- llply(1:10000, function(x){
  data.frame(val = x,
             val2 = 2 * x,
             var3 = 2 / x,
             var4 = 4 * x,
             val5 = 4 / x)
}))
system.time(x <- rbindlist(x))

#더 나은 반복문
install.packages("foreach")
library(foreach)

foreach(i = 1:5) %do% {
  return(i)
}

foreach(i = 1:5, .combine = c) %do% { #결과를 벡터로 받음
  return(i)
}

foreach(i = 1:5, .combine = rbind) %do% { #결과를 행 방향으로 합친 데이터프레임 반환
  return(i)
}

foreach(i = 1:10, .combine = "+") %do% { #연산자 지정: 모든 결과의 합 반환
}

#병렬 처리
install.packages("doParallel")
library(doParallel)

registerDoParallel(cores = NULL) #몇 개의 프로세스를 사용할지 선택

#plyr의 병렬화
#{adl}{adl_}ply(.parallel = TRUE)

#foreach()의 병렬화
registerDoParallel(cores = 4)
big_data <- data.frame(value = runif(NROW(LETTERS) * 2000000),
                       group = rep(LETTERS, 2000000))
foreach(i = 1:800000) %dopar% {mean(big_data$value + i)}

#유닛 테스팅: 코드 단위(유닛)이 정확히 작동하는지 코드를 사용해 검증
install.packages("testthat")
library(testthat)

expect_true(x) #x가 참인가
expect_false(x) #x가 거짓인가
expect_equal(object, expected) #object가 기대되는 값 expected와 동일한가
expect_equivalent(x, y) #x가 y와 동등한가 

a <- 1:3
b <- 1:3
expect_equal(a, b)
expect_equivalent(a, b)

names(a) <- c("a", "b", "c")
expect_equal(a, b) #벡터에 부여한 이름이 다르므로 테스트 실패
expect_equivalent(a, b) #벡터에 부여한 이름을 무시하므로 테스트 성공

#expect_equal()을 사용한 테스트 방법
fib <- function(n){
  if(n == 0){return (1)}
  if(n > 0){return (fib(n - 1) + fib(n - 2))}
}
expect_equal(1, fib(0)) #같음 > 경고 메시지 출력 X
expect_equal(1, fib(1)) #버그 조건 > 같지 않다는 에러 메시지 출력

#test_that을 사용한 테스트 그룹화
fib <- function(n){
  if(n == 0 || n == 1){return (1)}
  if(n >= 2){return (fib(n - 1) + fib(n - 2)}
}
test_that("base test", {
  expect_equal(1, fib(0)),
  expect_equal(1, fib(1))
})
test_that("recursion test", {
  expect_equal(2, fib(2)),
  expect_equal(3, fib(3)),
  expect_equal(5, fib(4))
})

#디버깅
#print(): 객체를 화면에 출력
#paste(): 객체를 문자열로 편리하게 변환
paste("a", 1, 2, "b", "c")
paste("A", 1:6)
paste("A", 1:6, sep = "") #문자를 붙일 때의 구분자 설정
paste("A", 1:6, sep = "", collapse = ",") #결과를 하나의 문자열로 만들 때

#spritf(): 주어진 인자들을 특정한 규칙에 맞게 문자열로 변환해 출력
sprintf("%d", 123)
sprintf("Number: %d", 123)
sprintf("Number: %d", "String: %s", 123, "hello")
sprintf("%.2f", 123.456) #소수점 둘째 자리까지만 출력
sprintf("%5d", 123) #일의 자리 이상의 수를 5자리로 고정

#cat(): 주어진 입력을 출력후 행을 바꾸지 않음
cat("hi")
cat("hi", "\n") #개행
sum_to_ten <- function(){
  sum <- 0
  cat("Adding....")
  for (i in 1:10){
    sum <- sum + i
    cat(i, "...")
  }
  cat("Done!", "\n")
  return(sum)
}
sum_to_ten()

#browser(): 명령 수행 중지, 디버깅 모드 시작

#코드 수행시간 측정
#system.time(): 주어진 명령을 수행하는 데 걸린 시간
#elapsed time: 코드의 총 소요 시간

#코드 프로파일링 
#Rprof()
#summaryRprof()

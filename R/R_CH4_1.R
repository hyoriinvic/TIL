#4장 데이터 조작(벡터 기반 처리와 외부 데이터 처리)
data(iris)

#CSV 파일 입출력
read.csv("______.csv") #파일 읽기 기본형
read.csv("______.csv", header = FALSE) #header(컬럼명)이 없는 경우
read.csv("______.csv", stringsAsFactors = FALSE) #문자열을 '문자열' 타입으로 읽도록
read.csv("______.csv", na.strings = c("NIL")) #NA라는 문자열을 R이 인식하는 NA로 변환
write.csv(x, "_______.csv", row.names = FALSE) #행 이름은 제외하고 파일에 저장

#메모리에 있는 객체 모두 삭제(초기화)
rm(list = ls())

#데이터프레임 행/열 병합
#행 병합
rbind(c(1, 2, 3), c(4, 5, 6)) 
(x <- data.frame(id = c(1, 2), name = c("a", "b"), stringsAsFactors = FALSE))
#열 병합
cbind(c(1, 2, 3), c(4, 5, 6)) 
(y <- cbind(x, greek = c("alpha", "beta"), stringAsFactors = FALSE)) #데이터프레임에 열 추가

#apply 계열 함수

#apply()
d <- matrix(1:9, ncol = 3) #3X3 행렬
apply(d, 1, sum) #행렬(d)의 각 행(1)의 합(sum)을 구함
apply(d, 2, sum) #행렬(d)의 각 열(2)의 합(sum)을 구함
#행/열의 합 또는 평균을 구하는 함수는 이미 존재

#lapply(): 리스트 반환 > 해당 결과를 벡터/데이터프레임으로 변환
(result <- lapply(1:3, function(x){x * 2}))
unlist(result) #결과를 벡터로 변환
#인자로 리스트를 받을 때,
(x <- list(a = 1:3, b = 4:6))
lapply(x, mean) #저장된 리스트에서 각 변수마다 평균 계산
#데이터프레임에 lapply() 적용
#이 경우 다시 데이터프레임으로 변환하려면,
#unlist() > matrix() > as.data.frame() > names()의 과정을 거쳐야 함
d <- as.data.frame(matrix(unlist(iris[, 1:4], mean)), 
                   ncol = 4, byrow = TRUE)
names(d) <- names(iris[, 1:4])
#하지만, 벡터로 변환되면서 하나의 데이터 타입으로 모두 형 변환되는 문제 발생
#do.call()로 변환 추천
data.frame(do.call(cbind, lapply(iris[, 1:4], mean)))

#sapply(): 행렬, 벡터 등의 데이터 타입으로 결과 반환
x <- sapply(iris[, 1:4], mean) #벡터 반환
class(x) #결과: "numeric" 숫자를 저장한 벡터
as.data.frame(t(X)) #데이터프레임으로 변환

#tapply(): 그룹별로 함수 적용
tapply(1:10, rep(1,10), sum)
tapply(1:10, 1:10 %% 2 == 1, sum) #홀수/짝수로 나눠서 각 그룹별 합 계산
m <- matrix(1:8, ncol = 2, 
            dimnames = list(c("spring", "summer", "fall", "winter"), c("male", "female")))
#반기별, 성별 셀의 합
tapply(m, list(c(1, 1, 2, 2, 1, 1, 2, 2), c(1, 1, 1, 1, 2, 2, 2, 2)), sum)

#mapply(): 다수의 인자를 함수에 
#난수 생성함수 rnorm(), runinf(), rpois(), rexp()
mapply(rnorm,
       c(1, 2, 3), #n
       c(0, 10, 100), #mean
       c(1, 1, 1)) #sd
library(doBy)

#doBy(): 데이터를 그룹으로 묶은 후 함수 호출하기
#install.packages("doBy")

#summaryBy(): 그룹별로 통계적 요약 값을 계산
summaryBy(Sepal.Width + Sepal.Length ~ Species, iris) #iris 데이터에서, Species에 따라 Sepal.Width, Sepal.Length를 요약

#orderBy(): 데이터프레임 정렬
orderBy(~ Sepal.Width, iris) #iris의 모든 데이터를 Sepal.Width를 기준으로 정렬
orderBy(~ Species + Sepal.Width, iris) #Species에 따라 정렬 후, Sepal.Width 기준으로 정렬

#sampleBy(): 각 그룹에서 샘플 추출
sampleBy(~ Species, frac = 0.1, data = iris)

#데이터 분리 및 병합

#split(): 리스트를 결과로 반환
split(iris, iris$Species)

#subset(): 조건을 만족하는 특정 부분만 취급
subset(iris, Species == "setosa")
subset(iris, Species == "setosa" & Sepal.Length > 5.0)
subset(iris, select = c(Sepal.Length, Species)) #특정 컬럼만 선택
subset(iris, select = -c(Sepal.Length, Species)) #특정 컬럼만 제외
iris[, !names(iris) %in% c("Sepal.Length", "Species")]

#데이터 병합
#merge(): 두 데이터프레임을 공통된 기준 값으로 묶음
x <- data.frame(name = c("a", "b", "c"), math = c(1, 2, 3))
y <- data.frame(name = c("c", "b", "a"), english = c(4, 5, 6))
merge(x, y)

x <- data.frame(name = c("a", "b", "c"), math = c(1, 2, 3))
y <- data.frame(name = c("c", "b", "d"), english = c(4, 5, 6))
merge(x, y) #공통된 부분만 출력
merge(x, y, all = TRUE) #전체 병합, 값이 없는 쪽에 NA 채움

#데이터 정렬
#sort(): 데이터 정렬 결과 반환
x <- c(20, 11, 33, 50, 47)
sort(x) #오름차순
sort(x, decreasing = TRUE) #내림차순
#order(): 주어진 인자를 정렬하기 위한 각 요소의 색인 반환
order(x)
order(x, decreasing = TRUE) #내림차순 
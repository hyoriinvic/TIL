#4장 데이터 조작(벡터 기반 처리와 외부 데이터 처리)
data(iris)

#데이터프레임 컬럼 접근: colname만으로 접근 가능한 함수

#with(): 필드 이름만으로 접근 가능
with(iris, {
  print(mean(Sepal.Length))
  print(mean(Sepal.Width))
})

#within(): with()와 비슷 + 데이터 수정 기능
(x <- data.frame(val = c(1, 2, 3, 4, NA, 5, NA)))
x <- within(x, { 
  val <- ifelse(is.na(val), median(val, na.rm = TRUE), val) #중앙값으로 결측치 대체
})
x$val[is.na(x$val)] <- median(x$val, na.rm = TRUE) #같은 결과
#within() 
iris[1, 1] = NA
median_per_species <- sapply(split(iris$Sepal.Length, iris$Species), median, na.rm = TRUE) #종별 중앙값을 구함
iris <- within(iris, {
  Sepal.Length <- ifelse(is.na(Sepal.Length), median_per_species[Species], Sepal.Length)
})

#attach(), detach(): 컬럼에 직접 접근

#조건을 만족하는 데이터 색인 구하기

#which(): 조건을 만족하는 행의 색인 반환
which(iris$Species == "setosa")

#which.min(): 최솟값이 저장된 색인 반환
#which.max(): 최댓값이 저장된 색인 반환
which.min(iris$Sepal.Length)
which.max(iris$Sepal.Length)

#그룹별 연산
#aggregate(): 데이터를 그룹으로 묶은 후 임의의 함수를 그룹에 적용
aggregate(Sepal.Width ~ Species, iris, mean)

#편리한 처리를 위한 데이터의 재표현: stack(), unstack()

#MySQL 연동
#RMySQL 패키지: 교재 설명 확인
install.packages("RMySQL", type = "source")
library(RMySQL)

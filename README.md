# FoodPick
> 주변 식당 메뉴를 확인하고, 픽업 주문을 진행하는 앱  
> 후기, 게시물, 쇼츠 영상, 채팅 기능으로 음식 관련 정보를 제공  

<br>

## 📌 프로젝트 소개
> 프로젝트 기간: 2025/12/10 ~ 2026/01/15  
> 개인 프로젝트  

**FoodPick**은 음식 픽업 주문 앱입니다.
- 식당 메뉴를 확인하고 주문하며
- 주문 현황과 이전 주문 내역을 확인하고
- 후기, 게시물, 쇼츠 영상, 채팅으로 음식 관련 정보를 얻을 수 있습니다.

<br>

## 📌 개발 환경

- **iOS Deployment Target** : 16.0+
- **Xcode** : 26.0.1
- **Swift** : 6.2
- **개발 도구** : Tuist

<br>
  
## 📌 구현 사항  

**Architecture**
- Tuist를 활용한 Clean Architecture 계층 모듈화로 의존성 관리 및 빌드 효율 향상
- TCA의 Dependency 관리와 Child Reducer 구조를 활용해 Side Effect 제어, 단방향 데이터 흐름 유지

**Network**
- Alamofire와 Router 패턴으로 API 통신 구조 표준화, Multipart/form-data 진행률 트래킹
- Interceptor를 활용한 동시성 환경에서의 Token Header 자동 주입 및 Retry 로직 구현
- SocketI.O 기반 실시간 채팅 WebSocket 구축 및 Active/Background 상태에 따른 연결 관리

**Database**
- CoreData 기반 비동기 컨텍스트 처리 및 자동 병합 로직을 통한 멀티 스레드 정합성 확보
- 복합 인덱스 적용 및 로컬 페이지네이션 구현으로 대용량 채팅 조회 성능 개선

**HLS Streaming**
- AVPlayer 풀링 시스템 Actor 기반 설계로 영상 전환 시 지연 시간 최소화 및 메모리 최적화
- AVPlayerLayer Wrapping을 통한 저수준 렌더링 제어로 SwiftUI 환경 내 스트리밍 성능 최적화
- 다음 영상의 스트림을 최소 버퍼와 저대역폭 모드로 preload, 실제 활성화 시 고품질로 전환
- 화질 선택 및 다국어 자막 선택 기능 제공, Optimistic UI를 적용한 영상 좋아요 처리

**Chat**
- Socket, Rest API, Local DB를 연동하여 실시간성 및 데이터 영속성을 보장하는 채팅 환경 구축
- Active/Background 상태에 따른 Socket 연결 생명주기를 최적화하여 네트워크 트래픽과 배터리 소모 최소화
- 현재 입장 중인 방을 제외한 채팅 Push 알림 표기, Deep Link 구현으로 해당 채팅방 즉시 진입 구현
- 채팅방별 읽지 않은 메세지 카운트 로직을 설계하여 앱 Badge 및 UI 표기

**WebView**
- WKScriptMessageHandler를 통한 웹의 이벤트 수신과 네이티브의 토큰 주입이 가능한 양방향 JS브릿지 설계
- 웹의 출석 완료 이벤트를 네이티브 Alert과 연동하여 사용자 인터페이스 통합

**Map**
- KakaoMaps SDK를 Wrapping, 길찾기 API 응답값을 지도에 표기
- CLLocationManager를 AsyncStream으로 래핑해 실시간 위치 데이터를 비동기 스트림으로 변환, 지도에 현재 위치 표기
- 단발성과 지속 트래킹 모드를 구분, NSLock을 활용해 Thread-safe한 Repository 설계

**Login**
- 애플/카카오 소셜 로그인 및 email 중복 확인을 통한 로그인 지원
- AccessToken 만료 시 RefreshToken을 활용한 토큰 자동 갱신 및 Retry 로직 구현, 키체인으로 토큰 관리
- RefreshToken 만료 시 로그인 화면으로 이동

**Payment**
- PG 결제 환경 지원 및 서버 영수증 검증으로 결제 안정성 향상

**View**
- Shape를 활용한 커스텀 TabBar, Cell 구성

**Frameworks**  
- SwiftUI(+UIKit), TCA, Alamofire, SocketIO, FCM, Kingfisher, CoreData, AVKit, AVFoundation, PhotosUI, KakaoMapsSDK

<br>

## 📌 기능
<table align="center">
  <tr>
    <th><code>홈</code></th>
    <th><code>주문 내역</code></th>
    <th><code>쇼츠 영상</code></th>
    <th><code>게시글</code></th>
    <th><code>프로필(채팅)</code></th>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/384efdb2-1a32-4494-86ae-16849a4c0a4e" alt="홈"></td>
    <td><img src="https://github.com/user-attachments/assets/1a15ac7e-acb6-44c9-9cb3-ba52c93f7252" alt="주문 내역"></td>
    <td><img src="https://github.com/user-attachments/assets/09220ee4-7cd1-4b80-9d57-5a649722ac6f" alt="쇼츠 영상"></td>
    <td><img src="https://github.com/user-attachments/assets/a4f22d76-2b3f-45eb-88f3-6ee51804bd55" alt="게시글"></td>
    <td><img src="https://github.com/user-attachments/assets/53a22c2c-473b-4de6-b436-35f1fc4a8e4a" alt="프로필(채팅)"></td>
  </tr>
</table>

**홈**
- 카테고리별 실시간 인기 가게, 주위 픽업 가게, 인기 검색어 표기
- 가게 정보와 메뉴 표기, 장바구니 담기, PG 결제 기능
- 도보 길찾기 결과 카카오 지도에 표기, 현재 위치 트래킹
- Web과 연동한 출석 체크 이벤트 배너


**주문 내역**
- 주문 현황(주문 승인, 조리 중 등의 단계 및 시간) 및 이전 주문 내역 표기
- 주문 내역 상세(단계 별 시간, 주문 메뉴, 가격 등) 표기
- 별점, 사진, 텍스트로 후기 작성/수정/삭제


**쇼츠 영상**
- 실시간 스트리밍 기반 쇼츠 영상 재생, 영상 딜레이 최소화(pooling, preload)
- 화질 및 다국어 자막 설정, 영상 좋아요 지원


**게시글**
- 현재 위치 기반 설정 범위 내 게시글 표기
- 영상/사진 개수에 따른 그리드 분기
- 검색을 통한 식당 선택, 사진/영상, 텍스트로 게시물 작성/수정/삭제
- 댓글 작성/수정/삭제


**프로필(채팅)**
- 프로필 사진, 닉네임 수정
- 다른 사용자 닉네임으로 검색
- 작성 게시물 모아보기(내 프로필은 좋아요한 게시물도 표기)
- 1:1 채팅 기능 제공(사진, 영상, 텍스트), 채팅방별 안읽은 메세지 카운팅
- 원격 Push 알림 제공, 터치 시 해당 채팅방으로 이동

<br>

## 📌 설치 및 실행

### 1. 프로젝트 클론
```bash
git clone https://github.com/kyhlsd/FoodPick.git
cd FoodPick
```

### 2. Tuist 설치
```bash
curl -Ls https://install.tuist.io | bash
```

### 3. 의존성 설치 및 프로젝트 생성
```bash
tuist install
tuist generate
```

### 4. 빌드 및 실행
- Xcode에서 타겟 디바이스 선택 후 실행 (⌘ + R)

> **참고**: API 사용을 위해 `Secrets/` 파일이 필요합니다.

<br>

## 연락처

- **GitHub**: [@kyhlsd](https://github.com/kyhlsd)
- **Email**: kmyghn@gmail.com


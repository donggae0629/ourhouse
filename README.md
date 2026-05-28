# OurHouse2

`OurHouse2`는 하숙생의 식사 신청과 하숙 생활을 더 편리하게 관리하기 위한 Flutter 모바일 앱입니다.

## 주요 기능

- Supabase 기반 이메일/비밀번호 로그인 및 회원가입
- 하숙집 구성원 프로필 관리
- 조식/중식/석식 식사 신청 상태 확인 및 신청/취소
- 실시간 데이터 스트리밍을 통한 현재 신청자 현황 표시
- 간단하고 직관적인 모바일 UI

## 프로젝트 구조

- `lib/main.dart` - 앱 진입점 및 Supabase 초기화
- `lib/views/login_page.dart` - 로그인 및 회원가입 화면
- `lib/views/home_page.dart` - 홈 화면 및 식사 신청 UI
- `pubspec.yaml` - Flutter 의존성 및 앱 메타데이터
- `assets/` - 앱에서 사용하는 이미지와 리소스

## 사용 기술

- Flutter
- Supabase (`supabase_flutter`)
- Google Fonts (`google_fonts`)
- URL Launcher (`url_launcher`)

## 시작하기

1. Flutter SDK 설치
   - https://docs.flutter.dev/get-started/install
2. 프로젝트 의존성 설치
   ```bash
   flutter pub get
   ```
3. 앱 실행
   ```bash
   flutter run
   ```

## Supabase 설정

현재 `lib/main.dart`에 Supabase URL과 익명 키가 하드코딩되어 있습니다. 실 서비스에서는 보안을 위해 별도의 환경 변수 또는 시크릿 관리 방법을 사용하는 것이 좋습니다.

## 개발 참고

- `LoginPage`는 사용자 로그인 및 회원가입 흐름을 제공합니다.
- `HomePage`는 현재 식사 신청 가능 시간과 신청자 목록을 보여줍니다.
- `Supabase.instance.client.auth.currentUser`로 로그인된 사용자를 확인합니다.
- `meal_applications` 및 `profiles` 테이블이 앱 로직에 사용됩니다.

## 테스트 계정 정보

아래 계정은 앱 실행 확인용 로그인 정보입니다.

- 이메일: `test@gmail.com`
- 비밀번호: `test1234`

> 현재 이 작업 환경에서는 Supabase 서버에 대한 DNS/네트워크 연결이 제한되어 있어 계정 생성 요청을 직접 실행하지 못했습니다. 따라서 실제 사용 전 Supabase 콘솔에서 계정 상태를 확인하거나 테스트 계정을 직접 생성해 주세요.

## 라이선스

이 프로젝트는 별도의 라이선스가 지정되지 않았습니다.

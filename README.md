# reDish

Egy Flutter alapú bevásárlólista és otthoni készletkezelő alkalmazás magyar felhasználók számára. Segít kezelni a bevásárlólistákat, követni az otthoni készletet, figyelni a lejárati dátumokat, és AI-val recepteket generálni abból, amit épp otthon van.

## Mit tud ez az app?

- **Bevásárlólista**: Kategóriákba rendezett termékekkel könnyen kezelhető bevásárlólisták
- **Otthoni készlet**: Kövesd, mi van otthon és mikor jár le
- **AI termék szkennelés**: Fényképezd le vagy írd be a terméket, az AI kinyeri az infókat
- **Recept generálás**: Az AI receptet készít abból, amit otthon találsz, prioritizálva a hamarosan lejáró dolgokat
- **Több profil**: Több felhasználó (pl. családtagok) színkódolt azonosítással
- **Lejárati figyelő**: Színes jelzésekkel mutatja, mi jár le hamarosan

## Mire lesz szükséged?

Mielőtt nekiállsz, ezeket telepítsd le:

- **Flutter SDK**: 3.5.4 vagy újabb
  - Innen töltheted: [flutter.dev](https://docs.flutter.dev/get-started/install)
  - Ellenőrzés: `flutter --version`
- **Dart SDK**: Flutter-rel együtt jön, nem kell külön
- **Git**: A kód letöltéséhez
- **IDE**: Android Studio, VS Code vagy IntelliJ IDEA Flutter bővítményekkel
- **Platform specifikus cuccok** (attól függ, mire akarod futtatni):
  - **Android**: Android Studio Android SDK-val
  - **iOS**: Xcode (csak macOS-on)
  - **Web**: Chrome (ha weben akarod futtatni)

## Hogyan állítsd be?

### 1. Töltsd le a kódot

```bash
git clone <repository-url>
cd coo_list
```

### 2. Telepítsd a függőségeket

Egyszerűen futtasd:

```bash
flutter pub get
```

### 3. Állítsd be a környezeti változókat

Hozz létre egy `.env` fájlt a projekt gyökérkönyvtárában (ugyanott, ahol a `pubspec.yaml` van) ezekkel a változókkal:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
OPENROUTER_URL=https://openrouter.ai/api/v1/chat/completions
OPENROUTER_API_KEY=your_openrouter_api_key
```

#### Supabase kulcsok beszerzése

1. Menj a [supabase.com](https://supabase.com)-ra és hozz létre egy projektet (ingyenes)
2. A projektben menj a **Settings** → **API** menüpontra
3. Másold ki a **Project URL**-t → Ez lesz a `SUPABASE_URL`
4. Másold ki az **anon/public key**-t → Ez lesz a `SUPABASE_ANON_KEY`

#### OpenRouter API kulcs

1. Regisztrálj a [openrouter.ai](https://openrouter.ai)-n
2. Menj a **Keys** fülre
3. Hozz létre egy új API kulcsot
4. Másold ki → Ez lesz a `OPENROUTER_API_KEY`
5. Az URL általában: `https://openrouter.ai/api/v1/chat/completions` (ezt már beírtam fent)

**Fontos**: 
- Soha ne commitold a `.env` fájlt! (már benne van a `.gitignore`-ban, szóval véletlenül sem fog menni)
- Tartsd titokban az API kulcsaidat, ne oszd meg sehol

### 4. Ellenőrizd a Flutter beállításokat

Futtasd ezt:

```bash
flutter doctor
```

Ha van valami piros vagy sárga, javítsd ki, mielőtt továbbmész.

### 5. Futtasd az alkalmazást

#### Android/iOS (telefon vagy emulátor)

**Android**:
- Indíts el egy emulátort (Android Studio-ból) vagy dugd be a telefonodat
- Ha telefon, kapcsold be az USB hibakeresést
- Futtasd: `flutter run`

**iOS** (csak macOS):
- Indíts el egy szimulátort vagy dugd be az iPhone-odat
- Futtasd: `flutter run`

#### Web

```bash
flutter run -d chrome
```

#### Asztali (Windows/Linux/macOS)

```bash
# Windows
flutter run -d windows

# Linux
flutter run -d linux

# macOS
flutter run -d macos
```

### 6. Build készítése (ha ki akarod adni)

**Android APK** (közvetlenül telepíthető):
```bash
flutter build apk --release
```

**Android App Bundle** (Play Áruházhoz):
```bash
flutter build appbundle --release
```

**iOS** (csak macOS):
```bash
flutter build ios --release
```

**Web**:
```bash
flutter build web --release
```

## Hogyan van felépítve a kód?

```
lib/
├── config/              # Konfigurációs cuccok (routing, Supabase)
├── data/               # Adat réteg (modellek, repository-k)
├── logic/              # Üzleti logika (BLoC-ok)
├── presentation/       # UI réteg (képernyők, widgetek)
├── services/          # Külső szolgáltatások (OpenRouter)
├── utils/             # Segédfüggvények
└── main.dart          # Itt indul az app
```

## Mivel készült?

- **Flutter**: ^3.5.4
- **Állapotkezelés**: flutter_bloc (BLoC)
- **Backend**: Supabase (PostgreSQL, auth, real-time)
- **AI**: OpenRouter (Google Gemini modellek)
- **Helyi tárolás**: shared_preferences
- **UI**: google_nav_bar, fl_chart, swipeable_tile

## Ha valami nem működik

### Gyakori problémák és megoldások

1. **A környezeti változók nem töltődnek be**
   - Nézd meg, hogy a `.env` fájl tényleg a gyökérkönyvtárban van-e (ahol a `pubspec.yaml`)
   - A változónevek kis-nagybetű érzékenyek, szóval pontosan egyezzenek
   - Indítsd újra az appot, ha módosítottad a `.env`-t

2. **Supabase nem csatlakozik**
   - Ellenőrizd, hogy a Supabase URL és API kulcs jó-e
   - Nézd meg, hogy a Supabase projekt aktív-e (nem pause-olva)
   - Ha van hibaüzenet, lehet hogy az RLS (Row Level Security) szabályzatok hiányoznak

3. **OpenRouter API hibák**
   - Nézd meg, hogy az API kulcs érvényes-e
   - Ellenőrizd, hogy van-e elég kredit az OpenRouter fiókodban
   - Az URL általában jó, de ha nem, nézd meg a dokumentációt

4. **Flutter függőségek problémája**
   - Próbáld ki: `flutter clean` majd `flutter pub get`
   - Ha még mindig nem jó, töröld a `pubspec.lock`-ot és futtasd újra a `flutter pub get`-et

5. **Build nem megy**
   - `flutter clean`
   - Töröld a `build/` mappát (ha van)
   - `flutter pub get`
   - Próbáld újra

## Hasznos linkek

- [Flutter dokumentáció](https://docs.flutter.dev/)
- [Supabase dokumentáció](https://supabase.com/docs)
- [OpenRouter dokumentáció](https://openrouter.ai/docs)
- [BLoC minta útmutató](https://bloclibrary.dev/)

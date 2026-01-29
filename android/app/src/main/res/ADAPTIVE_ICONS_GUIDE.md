# Android Adaptive Icons Setup

For modern Android (8.0+), you can create adaptive icons with separate foreground and background layers.

## Option 1: Using Provided Icons (Basic)
The icons in the mipmap folders can be used directly. Just copy them to your project's res folder.

## Option 2: Adaptive Icons (Recommended for Android 8.0+)

### Step 1: Create background resource
Create `android/app/src/main/res/values/ic_launcher_background.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#FFFFFF</color>
</resources>
```

### Step 2: Create adaptive icon XML
Create `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
```

### Step 3: Create round icon variant
Create `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
```

### Step 4: Add foreground icons
You'll need to create foreground layer icons. You can:
1. Use the same icons as foreground (simple approach)
2. Create separate foreground layer with the logo only (professional approach)

For the simple approach, duplicate the ic_launcher.png files and rename them to ic_launcher_foreground.png in each mipmap folder.

## Testing
Test your adaptive icons on different Android devices to see how they appear with:
- Square masks
- Rounded square masks
- Circle masks
- Squircle masks

## Colors Used in Logo
- Navy Blue: #0D1B2A
- Orange/Gold: #F5A623
- White Background: #FFFFFF

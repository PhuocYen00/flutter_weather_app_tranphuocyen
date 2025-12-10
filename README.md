# 🌤️ Flutter Weather App – Tran Phuoc Yen

A modern and fully-featured Flutter weather application using the OpenWeatherMap API.
The app displays current weather, hourly and daily forecasts, AQI, offline caching, city search, multilingual support (Vietnamese / English), and more.

---

## 📺 Demo

**Video Demo:** https://drive.google.com/file/d/1AWknuGAn_gwBlYSE0I3SLYWmCRpZsOkU/view

---

## ✨ Main Features

### 🌡️ Current Weather
- Temperature & Feels-like temperature
- Weather description + icon
- City & country
- Last updated time
- Dynamic background based on weather condition


### 📊 Thông tin chi tiết
- Humidity
- Pressure
- Visibility
- Wind speed & direction
- UV Index
- Sunrise / Sunset times

### 📅 Forecast
- Hourly forecast (next ~24 hours)
- Daily forecast (up to 7 days)
- Min / Max temperatures
- Rain probability (POP)

### 🔍 Search System
- Search weather by city name
- Search history
- Favorite cities (up to 5)
- Quick access from history / favorite list

### 📍 Location Service
- Auto fetch current GPS location
- Full permission handling (allow / deny / permanently denied)
- When denied → show instructions & allow manual city input

### 📡 Offline / Cache
- Cache the latest weather + forecast
- Display cached data when offline
- Show timestamp of cached data

### ⚙️ Settings
- Temperature unit: °C ⇆ °F
- Wind speed: m/s, km/h, mph
- Time format: 12h / 24h
- Language: English / Vietnamese
- Online / offline connection indicator

### 🧪 Air Quality (AQI) & Alerts
- Fetch AQI by location
- AQI level classification (Good / Moderate / Unhealthy / …)
- PM2.5 & PM10 details
- Warning banner when AQI is unhealthy


---

## 🧰 Công nghệ sử dụng (Tech Stack) ##
| Package              | Version | Purpose                    |
| -------------------- | ------: | -------------------------- |
| flutter              |     3.x | Main framework             |
| http                 |  ^1.1.0 | API requests               |
| provider             |  ^6.1.1 | State management           |
| geolocator           | ^10.1.0 | Get user location          |
| geocoding            |  ^2.1.1 | Reverse geocoding          |
| shared_preferences   |  ^2.2.2 | Local storage / caching    |
| connectivity_plus    |  ^5.0.2 | Network status detection   |
| intl                 | ^0.18.1 | Date/time formatting       |
| cached_network_image |  ^3.3.0 | Cache weather icons        |
| flutter_dotenv       |  ^6.0.0 | Secure API key with `.env` |

---

## 📸 Screenshot ##
<img width="699" height="852" alt="image" src="https://github.com/user-attachments/assets/88d47c73-2471-4368-8f48-24cd19a7a7fc" />
<img width="733" height="849" alt="image" src="https://github.com/user-attachments/assets/0d2d5822-71cc-4168-af97-557dc3ce0355" />
<img width="662" height="860" alt="image" src="https://github.com/user-attachments/assets/18cdac12-0ad0-4147-8394-b189fb3f2b08" />
<img width="596" height="864" alt="image" src="https://github.com/user-attachments/assets/73da0ce7-cbc5-48cf-9d30-2c21f105e854" />
<img width="639" height="865" alt="image" src="https://github.com/user-attachments/assets/bc66183f-747d-43fd-b11e-307643a07c83" />

---

## 🚀 Installation & Run Guide ##

### 1️⃣ Clone the repository ###
```sh
git clone https://github.com/PhuocYen00/flutter_weather_app_tranphuocyen.git
cd flutter_weather_app_tranphuocyen
```

### 2️⃣ Install dependencies ###

`sh
flutter pub get
` 

### 3️⃣ Configure your API key ###
Create .env from the example file:
` cp .env.example .env `

Open .env and add your API key:
` OPENWEATHER_API_KEY=your_api_key_here `

### 4️⃣ Run the app ###
` flutter run `

---

## Author ##

**Name:** Tran Phuoc Yen

**Student ID:** 2224802010093

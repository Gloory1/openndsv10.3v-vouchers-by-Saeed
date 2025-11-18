:root {
    --bg-1: #143d29;       /* أخضر غامق */
    --bg-2: #0f2027;       /* أسود مزرق */
    --title-color: #FFD700; /* ذهبي */
    --btn-bg: linear-gradient(to bottom, #FFD700, #C5A028); /* زر ذهبي */
    --btn-text: #143d29;   /* نص الزر غامق */
    --glow-color: rgba(255, 215, 0, 0.5); /* توهج ذهبي */
    --card-padding: clamp(20px, 5vw, 40px); /* مسافة داخلية متغيرة */
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    /* استخدام الخطوط الافتراضية للنظام لسرعة التحميل */
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    /* منع تكبير الخط التلقائي في بعض المتصفحات */
    -webkit-text-size-adjust: 100%; 
    -moz-text-size-adjust: 100%;
    text-size-adjust: 100%;
}

body {
    background: linear-gradient(135deg, var(--bg-1), var(--bg-2));
    background-size: 400% 400%;
    animation: gradientBG 15s ease infinite;
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    text-align: center;
    direction: rtl;
    padding: 15px;
    overflow-x: hidden;
}

/* --- الكارت --- */
.card, .offset, .login-form, .container {
    background: rgba(255, 255, 255, 0.1) !important;
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border-radius: 25px;
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-top: 1px solid rgba(255, 255, 255, 0.5);
    box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5);
    
    width: 90%; 
    max-width: 450px;
    
    /* استخدام padding بكسل ثابت ومحكوم */
    padding: 30px 20px;
    margin: auto;
    color: #fff;
    position: relative;
    z-index: 1;
    animation: slideUpFade 0.8s ease-out forwards;
}

.card::before, .card::after { display: none; }

/* --- اللوجو --- */
img, .logo {
    /* حجم ثابت بالبكسل لمنع التشوه */
    width: 100px; 
    height: 100px;
    margin: 0 auto 20px;
    border-radius: 50%;
    background-color: #fff;
    padding: 5px;
    box-shadow: 0 0 25px var(--glow-color);
    object-fit: contain;
    display: block;
    transition: transform 0.4s;
}
img:hover { transform: scale(1.05) rotate(5deg); }

/* --- العناوين (Fixed Logic) --- */
h1, .insert>h1 {
    /* معادلة تعتمد على عرض الشاشة مش إعدادات الخط */
    /* الترجمة: الخط هيكون 28 بكسل كحد أدنى و 38 بكسل كحد أقصى */
    font-size: clamp(28px, 6vw, 38px); 
    margin: 10px 0 20px;
    font-weight: 800;
    color: var(--title-color);
    text-shadow: 0 2px 10px rgba(0,0,0,0.4);
    line-height: 1.2;
    animation: none;
}

h2 { 
    font-size: clamp(16px, 4vw, 20px); 
    opacity: 0.9; 
    margin-bottom: 20px; 
    font-weight: 600;
}

/* --- حقول الإدخال --- */
input[type='text'], input[type='password'], input[type='number'], input[type='tel'] {
    width: 100%;
    padding: 0 15px; /* تصفير البادينج الرأسي عشان الارتفاع يظبط */
    
    /* ارتفاع ثابت ومقدس */
    height: 55px !important;
    line-height: 55px !important;
    
    border: none !important;
    border-radius: 50px;
    background: rgba(255, 255, 255, 0.95) !important;
    
    /* حجم خط بالبكسل عشان يفضل جوه الصندوق وميخرجش */
    font-size: 20px !important; 
    font-weight: 700;
    text-align: center;
    color: #333 !important;
    margin-bottom: 15px;
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    transition: 0.3s;
}

input:focus {
    outline: none;
    transform: scale(1.01);
    box-shadow: 0 0 20px var(--glow-color);
}

/* --- الأزرار --- */
button, .btn, input[type='submit'] {
    background: var(--btn-bg) !important;
    color: var(--btn-text) !important;
    border: none !important;
    padding: 0;
    
    height: 55px !important;
    line-height: 55px !important; /* توسيط الكلام رأسياً */
    
    /* حجم خط ثابت ومحسوب */
    font-size: 22px !important; 
    
    border-radius: 50px;
    cursor: pointer;
    width: 100%;
    font-weight: 800;
    box-shadow: 0 10px 25px rgba(0,0,0,0.3);
    margin-top: 15px;
    transition: all 0.2s ease;
}

button:hover, input[type='submit']:hover {
    transform: translateY(-3px);
    filter: brightness(1.1);
    box-shadow: 0 15px 35px var(--glow-color);
}

button:active { transform: scale(0.97); }

/* --- الصناديق الفرعية --- */
.info, .insert {
    background: linear-gradient(to bottom right, rgba(255,255,255,0.15), rgba(255,255,255,0.05)) !important;
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    border-radius: 20px;
    padding: 15px;
    margin-bottom: 20px;
    font-size: 16px; /* تثبيت الحجم */
}

big-red { 
    color: #fff !important; 
    font-weight: 800; 
    font-size: 20px; /* تثبيت الحجم */
    display: block; 
    margin: 10px 0; 
    text-shadow: 0 2px 4px rgba(0,0,0,0.3); 
}

.footer, copy-right {
    margin-top: 25px; 
    display: block; 
    font-size: 12px; 
    color: rgba(255,255,255,0.6);
}

/* --- Animations --- */
@keyframes gradientBG {
    0% { background-position: 0% 50%; }
    50% { background-position: 100% 50%; }
    100% { background-position: 0% 50%; }
}

@keyframes slideUpFade {
    from { opacity: 0; transform: translateY(30px); }
    to { opacity: 1; transform: translateY(0); }
}

/* --- ضمان للموبايلات القديمة والصغيرة جداً --- */
@media (max-width: 350px) {
    .card { padding: 20px 10px; }
    h1 { font-size: 24px; } /* تصغير العنوان يدوياً للشاشات الميكروسكوبية */
    input, button { 
        height: 45px !important; 
        line-height: 45px !important; 
        font-size: 18px !important; 
    }
}

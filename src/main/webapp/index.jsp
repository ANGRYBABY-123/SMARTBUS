<%@ page contentType="text/html;charset=UTF-8" %>
<%-- Landing page â€” no redirect --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>CommuteSafe â€“ Know your bus is safe. Get to work on time.</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        * { box-sizing: border-box; }
        html { scroll-behavior: smooth; }
        body { font-family: 'Segoe UI', sans-serif; margin: 0; background: #fff; color: #111; }

        /* NAV */
        .top-nav {
            position: sticky; top: 0; z-index: 100;
            background: rgba(0,0,0,0.95); backdrop-filter: blur(8px);
            padding: 14px 40px; display: flex; align-items: center; justify-content: space-between;
        }
        .nav-brand { font-size: 1.3rem; font-weight: 900; color: #fff; letter-spacing: -0.5px; text-decoration: none; }
        .nav-brand span { color: #00c853; }
        .nav-cta {
            background: #00c853; color: #000; border: none; border-radius: 8px;
            padding: 9px 22px; font-size: 0.88rem; font-weight: 800;
            text-decoration: none; transition: background .2s;
        }
        .nav-cta:hover { background: #00a846; color: #000; }
        .nav-links { display: flex; align-items: center; gap: 4px; }
        .nav-link-item {
            color: rgba(255,255,255,0.7); text-decoration: none; font-size: 0.85rem;
            font-weight: 600; padding: 7px 14px; border-radius: 8px; transition: all .2s;
        }
        .nav-link-item:hover { color: #fff; background: rgba(255,255,255,0.1); }
        @media (max-width: 640px) { .nav-links { display: none; } }

        /* HERO */
        .hero {
            min-height: 92vh;
            background: linear-gradient(135deg, #000 0%, #0d1b2a 60%, #1a3c5e 100%);
            display: flex; align-items: center; justify-content: center;
            text-align: center; padding: 80px 24px 60px;
        }
        .hero-inner { max-width: 760px; }
        .hero-badge {
            display: inline-flex; align-items: center; gap: 6px;
            background: rgba(0,200,83,0.15); color: #00c853;
            border: 1px solid rgba(0,200,83,0.35);
            border-radius: 40px; padding: 5px 16px; font-size: 0.78rem; font-weight: 700;
            margin-bottom: 28px; letter-spacing: .5px;
        }
        .hero h1 { font-size: clamp(2.4rem, 6vw, 4rem); font-weight: 900; color: #fff; line-height: 1.1; margin-bottom: 20px; }
        .hero h1 span { color: #00c853; }
        .hero p { font-size: 1.1rem; color: #94a3b8; margin-bottom: 36px; line-height: 1.7; max-width: 580px; margin-left: auto; margin-right: auto; }
        .hero-btns { display: flex; gap: 14px; justify-content: center; flex-wrap: wrap; }
        .btn-hero-primary {
            background: #00c853; color: #000; border: none; border-radius: 10px;
            padding: 14px 32px; font-size: 1rem; font-weight: 800;
            text-decoration: none; transition: all .2s;
        }
        .btn-hero-primary:hover { background: #00a846; color: #000; transform: translateY(-2px); }
        .btn-hero-outline {
            background: transparent; color: #fff; border: 2px solid rgba(255,255,255,0.3); border-radius: 10px;
            padding: 14px 32px; font-size: 1rem; font-weight: 700;
            text-decoration: none; transition: all .2s;
        }
        .btn-hero-outline:hover { border-color: #fff; color: #fff; }

        /* SECTIONS */
        .section { padding: 90px 24px; }
        .section-label { font-size: 0.75rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #3b82f6; margin-bottom: 10px; }
        .section-title { font-size: clamp(1.8rem,4vw,2.8rem); font-weight: 900; line-height: 1.15; }
        .section-sub { font-size: 1rem; color: #64748b; margin-top: 14px; max-width: 560px; }

        /* ABOUT */
        .about-section { background: #fff; padding: 90px 24px; }
        .about-section .section-label { color: #3b82f6; }
        .about-card {
            background: #f8fafc; border-radius: 20px; border: 1.5px solid #e2e8f0;
            padding: 48px 44px; max-width: 860px; margin: 0 auto;
        }
        .about-card p {
            font-size: 1.02rem; color: #374151; line-height: 1.85;
            margin-bottom: 20px;
        }
        .about-card p:last-child { margin-bottom: 0; }

        /* PROBLEM */
        .problem-bg { background: #f8fafc; }
        .problem-card {
            background: #fff; border-radius: 16px; border: 1.5px solid #e2e8f0;
            padding: 28px 24px; height: 100%; transition: box-shadow .2s, transform .2s;
        }
        .problem-card:hover { box-shadow: 0 12px 40px rgba(0,0,0,0.08); transform: translateY(-4px); }
        .problem-icon { font-size: 2rem; margin-bottom: 14px; }
        .problem-card h4 { font-weight: 800; font-size: 1rem; margin-bottom: 8px; }
        .problem-card p { font-size: 0.875rem; color: #64748b; margin: 0; line-height: 1.6; }

        /* SOLUTION */
        .solution-bg { background: linear-gradient(135deg, #000 0%, #0d1b2a 100%); color: #fff; }
        .solution-bg .section-label { color: #00c853; }
        .solution-bg .section-title { color: #fff; }
        .solution-bg .section-sub { color: #94a3b8; }
        .sol-item { display: flex; gap: 16px; align-items: flex-start; margin-bottom: 24px; }
        .sol-icon {
            width: 44px; height: 44px; border-radius: 10px;
            background: rgba(0,200,83,0.15); color: #00c853;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.2rem; flex-shrink: 0;
        }
        .sol-item h5 { font-weight: 700; margin: 0 0 4px; font-size: 0.95rem; color: #fff; }
        .sol-item p { font-size: 0.85rem; color: #94a3b8; margin: 0; }

        /* FEATURES */
        .feature-card { background: #fff; border-radius: 20px; border: 1.5px solid #e2e8f0; padding: 36px 30px; height: 100%; }
        .feature-num { display: inline-flex; align-items: center; justify-content: center; width: 36px; height: 36px; border-radius: 10px; font-weight: 900; font-size: 0.9rem; margin-bottom: 16px; }
        .feature-card h3 { font-weight: 900; font-size: 1.25rem; margin-bottom: 16px; }
        .feature-card ul { list-style: none; padding: 0; margin: 0 0 20px; }
        .feature-card ul li { padding: 6px 0; font-size: 0.88rem; color: #475569; display: flex; align-items: flex-start; gap: 8px; }
        .feature-card ul li::before { content: 'âœ“'; font-weight: 900; flex-shrink: 0; }
        .benefit-tag { display: inline-flex; align-items: center; gap: 6px; border-radius: 8px; padding: 8px 14px; font-size: 0.8rem; font-weight: 700; }

        /* BUILT FOR */
        .built-bg { background: #0f172a; color: #fff; }
        .built-bg .section-label { color: #00c853; }
        .built-bg .section-title { color: #fff; }
        .built-card { background: #1e293b; border-radius: 16px; border: 1px solid #334155; padding: 28px 24px; height: 100%; }
        .built-card i { font-size: 2rem; margin-bottom: 12px; display: block; color: #00c853; }
        .built-card h5 { font-weight: 800; color: #fff; margin-bottom: 6px; }
        .built-card p { font-size: 0.85rem; color: #94a3b8; margin: 0; }

        /* IMPACT */
        .impact-card { background: #fff; border-radius: 16px; border: 1.5px solid #e2e8f0; padding: 32px 28px; text-align: center; height: 100%; }
        .impact-icon { font-size: 2.4rem; margin-bottom: 14px; }
        .impact-card h4 { font-weight: 900; font-size: 1.1rem; margin-bottom: 8px; }
        .impact-card p { font-size: 0.85rem; color: #64748b; margin: 0; }

        /* CTA */
        .cta-section { background: linear-gradient(135deg, #000 0%, #0d1b2a 60%, #1a3c5e 100%); padding: 100px 24px; text-align: center; }
        .cta-section h2 { font-size: clamp(2rem,5vw,3.2rem); font-weight: 900; color: #fff; margin-bottom: 16px; }
        .cta-section h2 span { color: #00c853; }
        .cta-section p { font-size: 1rem; color: #94a3b8; margin-bottom: 40px; max-width: 500px; margin-left: auto; margin-right: auto; }

        /* FOOTER */
        .site-footer { background: #000; color: #475569; padding: 32px 40px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; font-size: 0.82rem; }
        .site-footer .brand { color: #fff; font-weight: 900; }
        .site-footer .brand span { color: #00c853; }
    </style>
</head>
<body>

<!-- NAV -->
<nav class="top-nav">
    <a href="${pageContext.request.contextPath}/" class="nav-brand">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 36 36" width="26" height="26" style="margin-right:7px;vertical-align:middle;flex-shrink:0" aria-hidden="true">
          <path d="M18 2.5L32 8.5L32 20C32 29 26 35 18 37C10 35 4 29 4 20L4 8.5Z" fill="#00c853"/>
          <path d="M18 7L29 12L29 20C29 27 24.2 32.5 18 34C11.8 32.5 7 27 7 20L7 12Z" fill="rgba(0,0,0,0.13)"/>
          <rect x="10.5" y="16.5" width="15" height="9.5" rx="2.2" fill="white"/>
          <rect x="11.5" y="13.5" width="13" height="4" rx="1.8" fill="rgba(255,255,255,0.92)"/>
          <rect x="12" y="17.8" width="3.5" height="3" rx="0.7" fill="#009c3b"/>
          <rect x="17.5" y="17.8" width="3.5" height="3" rx="0.7" fill="#009c3b"/>
          <circle cx="13.5" cy="26.2" r="2" fill="#009c3b"/>
          <circle cx="22.5" cy="26.2" r="2" fill="#009c3b"/>
        </svg>
        Commute<span>Safe</span>
    </a>
    <div class="nav-links">
        <a href="#about" class="nav-link-item">About</a>
        <a href="#problem" class="nav-link-item">Problem</a>
        <a href="#solution" class="nav-link-item">Solution</a>
        <a href="#features" class="nav-link-item">Features</a>
        <a href="#impact" class="nav-link-item">Impact</a>
    </div>
    <a href="${pageContext.request.contextPath}/users/login" class="nav-cta">Sign In</a>
</nav>

<!-- HERO -->
<section class="hero">
    <div class="hero-inner">
        <div class="hero-badge"><i class="bi bi-broadcast-pin"></i> Real-Time Bus Tracking</div>
        <h1>Know where your bus is.<br><span>Get to work on time.</span></h1>
        <p>CommuteSafe helps daily commuters track live bus locations, find nearby stops, and get instant delay alerts â€” so you never waste time waiting at the wrong place.</p>
        <div class="hero-btns">
            <a href="${pageContext.request.contextPath}/users/login" class="btn-hero-primary">
                <i class="bi bi-arrow-right-circle me-2"></i>Get Started
            </a>
            <a href="#about" class="btn-hero-outline">Learn More</a>
        </div>
    </div>
</section>

<!-- ABOUT -->
<section class="about-section" id="about">
    <div class="container">
        <div class="text-center mb-5">
            <div class="section-label">System Proposal</div>
            <h2 class="section-title">About CommuteSafe</h2>
            <p class="section-sub mx-auto">Understanding the problem we set out to solve.</p>
        </div>
        <div class="about-card">
            <p>CommuteSafe is a smart bus tracking and commuter assistance system designed to solve common problems faced by daily public transport users. Many commuters experience long and unpredictable waiting times, uncertainty about bus arrivals, difficulty finding nearby bus stops, and unnecessary transport costs caused by delays or missed buses. These challenges lead to wasted time, financial strain, stress, and safety concerns.</p>
            <p>The purpose of CommuteSafe is to improve the commuting experience by providing real-time bus tracking, estimated arrival times, and location-based services â€” giving passengers the information they need to plan their journeys more effectively and make confident decisions at every step of their commute.</p>
            <p>CommuteSafe is intended to be affordable and accessible for low-income commuters, built to run on entry-level smartphones with minimal data usage, so that the cost of the app is never a barrier to a better commuting experience.</p>
            <p>The expected impact of the system includes reduced waiting times, lower transport expenses, improved commuter safety, reduced stress, and better overall trip planning for the millions of people who rely on public buses every single day.</p>
        </div>
    </div>
</section>

<!-- PROBLEM -->
<section class="section problem-bg" id="problem">
    <div class="container">
        <div class="text-center mb-5">
            <div class="section-label">The Problem</div>
            <h2 class="section-title">What Daily Bus Users Struggle With</h2>
            <p class="section-sub mx-auto">Millions of workers rely on buses every day â€” but the system leaves them guessing.</p>
        </div>
        <div class="row g-4">
            <div class="col-md-6 col-lg-3">
                <div class="problem-card">
                    <div class="problem-icon">â³</div>
                    <h4>Unpredictable Waiting</h4>
                    <p>Long, unpredictable waiting times at bus stops with no indication of when the next bus will arrive.</p>
                </div>
            </div>
            <div class="col-md-6 col-lg-3">
                <div class="problem-card">
                    <div class="problem-icon">â“</div>
                    <h4>No Visibility</h4>
                    <p>No way to know if the bus is coming, already passed, or stuck in traffic somewhere ahead.</p>
                </div>
            </div>
            <div class="col-md-6 col-lg-3">
                <div class="problem-card">
                    <div class="problem-icon">ðŸ’¸</div>
                    <h4>Wasted Money</h4>
                    <p>Commuters spend extra money on taxis as backup whenever they're unsure if the bus is coming.</p>
                </div>
            </div>
            <div class="col-md-6 col-lg-3">
                <div class="problem-card">
                    <div class="problem-icon">ðŸ“</div>
                    <h4>Hard to Navigate</h4>
                    <p>Difficult to find the nearest bus stop when visiting new areas or traveling unfamiliar routes.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- SOLUTION -->
<section class="section solution-bg" id="solution">
    <div class="container">
        <div class="row align-items-center g-5">
            <div class="col-lg-5">
                <div class="section-label">Our Solution</div>
                <h2 class="section-title">Simple Bus Tracking for Workers</h2>
                <p class="section-sub mt-3">CommuteSafe removes the uncertainty from your daily commute â€” giving you the information you need, when you need it.</p>
            </div>
            <div class="col-lg-7">
                <div class="sol-item">
                    <div class="sol-icon"><i class="bi bi-geo-alt-fill"></i></div>
                    <div>
                        <h5>Real-time bus location and arrival times</h5>
                        <p>See exactly where your bus is on the map and get an accurate ETA for your stop.</p>
                    </div>
                </div>
                <div class="sol-item">
                    <div class="sol-icon"><i class="bi bi-pin-map-fill"></i></div>
                    <div>
                        <h5>Find the nearest bus stop from your location</h5>
                        <p>GPS-powered stop finder shows walking directions and all routes available at that stop.</p>
                    </div>
                </div>
                <div class="sol-item">
                    <div class="sol-icon"><i class="bi bi-bell-fill"></i></div>
                    <div>
                        <h5>Instant alerts for delays + backup options</h5>
                        <p>Get notified the moment a delay happens, with alternative buses and wait times shown automatically.</p>
                    </div>
                </div>
                <div class="sol-item">
                    <div class="sol-icon"><i class="bi bi-phone"></i></div>
                    <div>
                        <h5>Built for low-end phones and low data</h5>
                        <p>Designed to work smoothly even on affordable Android devices with limited mobile data.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- FEATURES -->
<section class="section" id="features">
    <div class="container">
        <div class="text-center mb-5">
            <div class="section-label">Key Features</div>
            <h2 class="section-title">Everything You Need to Commute with Confidence</h2>
        </div>
        <div class="row g-4">
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-num" style="background:#dbeafe;color:#2563eb;">01</div>
                    <h3>ðŸšŒ Live Bus Tracking</h3>
                    <ul>
                        <li>See your bus moving on the map in real time</li>
                        <li>Get accurate ETA for your specific stop</li>
                        <li>Auto-updates for traffic and delays</li>
                    </ul>
                    <div class="benefit-tag" style="background:#dbeafe;color:#1d4ed8;">
                        <i class="bi bi-check-circle-fill"></i>
                        Leave home at the right time â€” stop wasting hours waiting
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-num" style="background:#dcfce7;color:#16a34a;">02</div>
                    <h3>ðŸ“ Nearest Stop Finder</h3>
                    <ul>
                        <li>GPS finds the closest bus stations near you</li>
                        <li>Shows walking direction and distance</li>
                        <li>Lists all bus routes available at that stop</li>
                    </ul>
                    <div class="benefit-tag" style="background:#dcfce7;color:#15803d;">
                        <i class="bi bi-check-circle-fill"></i>
                        Easy to commute even in unfamiliar areas
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-num" style="background:#fef9c3;color:#b45309;">03</div>
                    <h3>â° Smart Delay Alerts</h3>
                    <ul>
                        <li>Instant notification if your bus is delayed or breaks down</li>
                        <li>App suggests other buses on nearby routes</li>
                        <li>Shows estimated wait time for backup options</li>
                    </ul>
                    <div class="benefit-tag" style="background:#fef9c3;color:#92400e;">
                        <i class="bi bi-check-circle-fill"></i>
                        Make fast decisions â€” avoid overpaying for taxis
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- BUILT FOR LOW-INCOME COMMUTERS -->
<section class="section built-bg" id="accessibility">
    <div class="container">
        <div class="text-center mb-5">
            <div class="section-label">Accessibility</div>
            <h2 class="section-title">Simple, Light, Affordable</h2>
            <p class="section-sub mx-auto" style="color:#94a3b8">Built specifically for the workers who rely on buses every single day.</p>
        </div>
        <div class="row g-4">
            <div class="col-sm-6 col-lg-3">
                <div class="built-card">
                    <i class="bi bi-phone"></i>
                    <h5>Works on cheap Android phones</h5>
                    <p>No need for a flagship smartphone â€” runs smoothly on any affordable device.</p>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="built-card">
                    <i class="bi bi-wifi"></i>
                    <h5>Uses minimal mobile data</h5>
                    <p>Lightweight design means you spend almost nothing on data to track your bus.</p>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="built-card">
                    <i class="bi bi-cloud-slash"></i>
                    <h5>Saves routes for offline use</h5>
                    <p>Your common routes are cached so you can view them even without a connection.</p>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="built-card">
                    <i class="bi bi-hand-index-thumb"></i>
                    <h5>Big buttons, clear layout</h5>
                    <p>Designed for anyone to use â€” no tech skills required, easy to navigate.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- IMPACT -->
<section class="section" id="impact">
    <div class="container">
        <div class="text-center mb-5">
            <div class="section-label">Impact</div>
            <h2 class="section-title">Real Benefits for Daily Users</h2>
            <p class="section-sub mx-auto">CommuteSafe directly improves the lives of commuters who can't afford to be late or waste money.</p>
        </div>
        <div class="row g-4">
            <div class="col-sm-6 col-lg-3">
                <div class="impact-card">
                    <div class="impact-icon">â±ï¸</div>
                    <h4>Cut Waiting Time</h4>
                    <p>Plan your trip with live data and leave home at the right moment â€” not too early or too late.</p>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="impact-card">
                    <div class="impact-icon">ðŸ’°</div>
                    <h4>Save Money</h4>
                    <p>Stop spending on taxis as backup. Know your bus is coming before you decide to take one.</p>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="impact-card">
                    <div class="impact-icon">ðŸ˜Œ</div>
                    <h4>Reduce Stress</h4>
                    <p>Remove the uncertainty of your commute. Arrive calmer and more focused for work.</p>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="impact-card">
                    <div class="impact-icon">ðŸ›¡ï¸</div>
                    <h4>Safer Commuting</h4>
                    <p>Spend less time standing in unsafe areas waiting â€” know exactly when your bus arrives.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- CTA -->
<section class="cta-section">
    <h2>Ready to ride <span>smarter</span>?</h2>
    <p>A practical tool for the people who rely on buses every day. Sign in or create your account now.</p>
    <div class="d-flex gap-3 justify-content-center flex-wrap">
        <a href="${pageContext.request.contextPath}/users/login" class="btn-hero-primary">
            <i class="bi bi-box-arrow-in-right me-2"></i>Sign In
        </a>
        <a href="${pageContext.request.contextPath}/users/login" class="btn-hero-outline">Create Account</a>
    </div>
</section>

<!-- FOOTER -->
<footer class="site-footer">
    <div>
        <div class="brand" style="font-size:1.1rem;font-weight:900;color:#fff;margin-bottom:4px;display:flex;align-items:center;gap:7px">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 28 28" width="22" height="22" aria-hidden="true">
              <path d="M14 2L25 7L25 15.5C25 22.5 20 27 14 28.5C8 27 3 22.5 3 15.5L3 7Z" fill="#00c853"/>
              <path d="M14 5.5L23 9.5L23 15.5C23 21.5 18.8 25.5 14 27C9.2 25.5 5 21.5 5 15.5L5 9.5Z" fill="rgba(0,0,0,0.12)"/>
              <rect x="8" y="13" width="12" height="8" rx="1.8" fill="white"/>
              <rect x="9" y="10.5" width="10" height="3.5" rx="1.4" fill="rgba(255,255,255,0.9)"/>
              <rect x="9.5" y="14" width="3" height="2.5" rx="0.6" fill="#009c3b"/>
              <rect x="14" y="14" width="3" height="2.5" rx="0.6" fill="#009c3b"/>
              <circle cx="10.5" cy="21.5" r="1.8" fill="#009c3b"/>
              <circle cx="17.5" cy="21.5" r="1.8" fill="#009c3b"/>
            </svg>
            Commute<span style="color:#00c853;">Safe</span>
        </div>
        <div style="font-size:0.78rem;">Safe, real-time commuting for everyone.</div>
    </div>
    <div style="display:flex;gap:24px;font-size:0.82rem;">
        <a href="#about" style="color:#475569;text-decoration:none;">About</a>
        <a href="#problem" style="color:#475569;text-decoration:none;">Problem</a>
        <a href="#features" style="color:#475569;text-decoration:none;">Features</a>
        <a href="#impact" style="color:#475569;text-decoration:none;">Impact</a>
        <a href="${pageContext.request.contextPath}/users/login" style="color:#00c853;text-decoration:none;font-weight:700;">Sign In</a>
    </div>
    <div style="font-size:0.78rem;">&copy; 2026 CommuteSafe. All rights reserved.</div>
</footer>

</body>
</html>

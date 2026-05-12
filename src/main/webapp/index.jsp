<%@ page contentType="text/html;charset=UTF-8" %>
<%-- Landing page — no redirect --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SmartBus – Know where your bus is. Get to work on time.</title>
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
        .feature-card ul li::before { content: '✓'; font-weight: 900; flex-shrink: 0; }
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
    <a href="${pageContext.request.contextPath}/" class="nav-brand">Smart<span>Bus</span></a>
    <a href="${pageContext.request.contextPath}/users/login" class="nav-cta">Sign In</a>
</nav>

<!-- HERO -->
<section class="hero">
    <div class="hero-inner">
        <div class="hero-badge"><i class="bi bi-broadcast-pin"></i> Real-Time Bus Tracking</div>
        <h1>Know where your bus is.<br><span>Get to work on time.</span></h1>
        <p>SmartBus helps daily commuters track live bus locations, find nearby stops, and get instant delay alerts — so you never waste time waiting at the wrong place.</p>
        <div class="hero-btns">
            <a href="${pageContext.request.contextPath}/users/login" class="btn-hero-primary">
                <i class="bi bi-arrow-right-circle me-2"></i>Get Started
            </a>
            <a href="#problem" class="btn-hero-outline">Learn More</a>
        </div>
    </div>
</section>

<!-- PROBLEM -->
<section class="section problem-bg" id="problem">
    <div class="container">
        <div class="text-center mb-5">
            <div class="section-label">The Problem</div>
            <h2 class="section-title">What Daily Bus Users Struggle With</h2>
            <p class="section-sub mx-auto">Millions of workers rely on buses every day — but the system leaves them guessing.</p>
        </div>
        <div class="row g-4">
            <div class="col-md-6 col-lg-3">
                <div class="problem-card">
                    <div class="problem-icon">⏳</div>
                    <h4>Unpredictable Waiting</h4>
                    <p>Long, unpredictable waiting times at bus stops with no indication of when the next bus will arrive.</p>
                </div>
            </div>
            <div class="col-md-6 col-lg-3">
                <div class="problem-card">
                    <div class="problem-icon">❓</div>
                    <h4>No Visibility</h4>
                    <p>No way to know if the bus is coming, already passed, or stuck in traffic somewhere ahead.</p>
                </div>
            </div>
            <div class="col-md-6 col-lg-3">
                <div class="problem-card">
                    <div class="problem-icon">💸</div>
                    <h4>Wasted Money</h4>
                    <p>Commuters spend extra money on taxis as backup whenever they're unsure if the bus is coming.</p>
                </div>
            </div>
            <div class="col-md-6 col-lg-3">
                <div class="problem-card">
                    <div class="problem-icon">📍</div>
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
                <p class="section-sub mt-3">SmartBus removes the uncertainty from your daily commute — giving you the information you need, when you need it.</p>
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
                    <h3>🚌 Live Bus Tracking</h3>
                    <ul>
                        <li>See your bus moving on the map in real time</li>
                        <li>Get accurate ETA for your specific stop</li>
                        <li>Auto-updates for traffic and delays</li>
                    </ul>
                    <div class="benefit-tag" style="background:#dbeafe;color:#1d4ed8;">
                        <i class="bi bi-check-circle-fill"></i>
                        Leave home at the right time — stop wasting hours waiting
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-num" style="background:#dcfce7;color:#16a34a;">02</div>
                    <h3>📍 Nearest Stop Finder</h3>
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
                    <h3>⏰ Smart Delay Alerts</h3>
                    <ul>
                        <li>Instant notification if your bus is delayed or breaks down</li>
                        <li>App suggests other buses on nearby routes</li>
                        <li>Shows estimated wait time for backup options</li>
                    </ul>
                    <div class="benefit-tag" style="background:#fef9c3;color:#92400e;">
                        <i class="bi bi-check-circle-fill"></i>
                        Make fast decisions — avoid overpaying for taxis
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
                    <p>No need for a flagship smartphone — runs smoothly on any affordable device.</p>
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
                    <p>Designed for anyone to use — no tech skills required, easy to navigate.</p>
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
            <p class="section-sub mx-auto">SmartBus directly improves the lives of commuters who can't afford to be late or waste money.</p>
        </div>
        <div class="row g-4">
            <div class="col-sm-6 col-lg-3">
                <div class="impact-card">
                    <div class="impact-icon">⏱️</div>
                    <h4>Cut Waiting Time</h4>
                    <p>Plan your trip with live data and leave home at the right moment — not too early or too late.</p>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="impact-card">
                    <div class="impact-icon">💰</div>
                    <h4>Save Money</h4>
                    <p>Stop spending on taxis as backup. Know your bus is coming before you decide to take one.</p>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="impact-card">
                    <div class="impact-icon">😌</div>
                    <h4>Reduce Stress</h4>
                    <p>Remove the uncertainty of your commute. Arrive calmer and more focused for work.</p>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="impact-card">
                    <div class="impact-icon">🛡️</div>
                    <h4>Safer Commuting</h4>
                    <p>Spend less time standing in unsafe areas waiting — know exactly when your bus arrives.</p>
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
    <div class="brand">Smart<span>Bus</span></div>
    <div>Know where your bus is. Get to work on time.</div>
    <div>&copy; 2026 SmartBus. All rights reserved.</div>
</footer>

</body>
</html>

        /* Sidebar */
        .sidebar {
            width: 240px; min-width: 240px; min-height: 100vh;
            background: linear-gradient(180deg, #0f172a 0%, #1e293b 100%);
            border-right: 1px solid #1e293b;
            padding: 24px 16px;
            display: flex; flex-direction: column;
        }
        .brand { font-size: 1.25rem; font-weight: 800; color: #fff; letter-spacing: -0.5px; margin-bottom: 32px; }
        .brand .dot { color: #6366f1; }
        .nav-section { font-size: 0.7rem; text-transform: uppercase; letter-spacing: 1.5px; color: #475569; margin: 16px 0 8px 8px; }
        .sidebar a {
            display: flex; align-items: center; gap: 10px;
            color: #94a3b8; text-decoration: none;
            padding: 9px 12px; border-radius: 8px;
            font-size: 0.88rem; font-weight: 500;
            transition: all 0.15s;
        }
        .sidebar a:hover, .sidebar a.active { background: #1e293b; color: #fff; }
        .sidebar a i { font-size: 1rem; width: 18px; text-align: center; }
        .sidebar a.danger { color: #f87171; }
        .sidebar a.danger:hover { background: rgba(248,113,113,0.1); color: #f87171; }
        .sidebar-footer { margin-top: auto; }

        /* Main content */
        .main { flex: 1; padding: 32px; overflow-y: auto; min-height: 100vh; }

        /* Header bar */
        .page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 32px; }
        .page-title { font-size: 1.6rem; font-weight: 800; color: #fff; }
        .page-subtitle { font-size: 0.85rem; color: #64748b; margin-top: 2px; }
        .admin-chip {
            background: #6366f1; color: #fff;
            padding: 4px 12px; border-radius: 20px;
            font-size: 0.8rem; font-weight: 600;
            display: flex; align-items: center; gap: 6px;
        }

        /* Stat cards */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; margin-bottom: 28px; }
        .stat-card {
            background: #1e293b; border-radius: 16px; padding: 20px;
            border: 1px solid #334155; position: relative; overflow: hidden;
        }
        .stat-card::before {
            content: ''; position: absolute; top: 0; left: 0;
            width: 4px; height: 100%; border-radius: 16px 0 0 16px;
        }
        .stat-card.blue::before { background: #6366f1; }
        .stat-card.green::before { background: #22c55e; }
        .stat-card.amber::before { background: #f59e0b; }
        .stat-card.red::before { background: #ef4444; }
        .stat-card.purple::before { background: #a855f7; }
        .stat-icon { font-size: 1.4rem; margin-bottom: 10px; }
        .stat-label { font-size: 0.75rem; text-transform: uppercase; letter-spacing: 1px; color: #64748b; margin-bottom: 4px; }
        .stat-value { font-size: 2rem; font-weight: 800; color: #fff; }

        /* Panels */
        .panel { background: #1e293b; border-radius: 16px; border: 1px solid #334155; overflow: hidden; }
        .panel-header { padding: 16px 20px; border-bottom: 1px solid #334155; font-weight: 700; font-size: 0.9rem; display: flex; align-items: center; gap: 8px; }
        .panel-body { padding: 16px 20px; }

        /* Quick action buttons */
        .action-btn {
            display: flex; flex-direction: column; align-items: center; gap: 6px;
            background: #0f172a; border: 1px solid #334155;
            color: #94a3b8; text-decoration: none;
            padding: 16px 12px; border-radius: 12px; font-size: 0.78rem;
            font-weight: 600; text-align: center; transition: all 0.15s;
            min-width: 90px;
        }
        .action-btn i { font-size: 1.4rem; }
        .action-btn:hover { background: #6366f1; border-color: #6366f1; color: #fff; transform: translateY(-2px); }

        /* Active trips table */
        .live-table { width: 100%; border-collapse: collapse; }
        .live-table th { font-size: 0.72rem; text-transform: uppercase; letter-spacing: 1px; color: #475569; padding: 8px 12px; border-bottom: 1px solid #334155; }
        .live-table td { padding: 12px 12px; border-bottom: 1px solid #1e293b; font-size: 0.88rem; color: #cbd5e1; }
        .live-table tr:last-child td { border-bottom: none; }
        .badge-live { background: rgba(34,197,94,0.15); color: #22c55e; padding: 3px 10px; border-radius: 20px; font-size: 0.72rem; font-weight: 700; }
        .btn-track { background: #6366f1; color: #fff; border: none; padding: 5px 14px; border-radius: 8px; font-size: 0.78rem; font-weight: 600; text-decoration: none; display: inline-flex; align-items: center; gap: 4px; }
        .btn-track:hover { background: #4f46e5; color: #fff; }
        .empty-row td { text-align: center; color: #475569; padding: 32px; }
    </style>
</head>
<body>
<div class="d-flex">
    <!-- Sidebar -->
    <div class="sidebar">
        <div class="brand">Smart<span class="dot">Bus</span></div>
        <div class="nav-section">Main</div>
        <a href="${pageContext.request.contextPath}/dashboard"><i class="bi bi-speedometer2"></i> Overview</a>
        <a href="${pageContext.request.contextPath}/trips/list"><i class="bi bi-arrow-left-right"></i> Trips</a>
        <a href="${pageContext.request.contextPath}/buses/list"><i class="bi bi-bus-front"></i> Fleet</a>
        <a href="${pageContext.request.contextPath}/routes/list"><i class="bi bi-map"></i> Routes</a>
        <a href="${pageContext.request.contextPath}/schedules/list"><i class="bi bi-calendar3"></i> Schedules</a>
        <div class="nav-section">Users</div>
        <a href="${pageContext.request.contextPath}/users/list"><i class="bi bi-people"></i> All Users</a>
        <div class="sidebar-footer">
            <hr style="border-color:#334155">
            <a href="${pageContext.request.contextPath}/users/logout" class="danger"><i class="bi bi-box-arrow-right"></i> Logout</a>
        </div>
    </div>

    <!-- Main -->
    <div class="main">
        <!-- Header -->
        <div class="page-header">
            <div>
                <div class="page-title">Fleet Command Center</div>
                <div class="page-subtitle">Real-time overview of your SmartBus operations</div>
            </div>
            <div class="admin-chip"><i class="bi bi-shield-fill-check"></i> Admin</div>
        </div>

        <!-- Stats -->
        <div class="stats-grid">
            <div class="stat-card blue">
                <div class="stat-icon">🚌</div>
                <div class="stat-label">Total Buses</div>
                <div class="stat-value">${totalBuses}</div>
            </div>
            <div class="stat-card green">
                <div class="stat-icon">⚡</div>
                <div class="stat-label">Active Trips</div>
                <div class="stat-value">${activeTripsCount}</div>
            </div>
            <div class="stat-card amber">
                <div class="stat-icon">🗺</div>
                <div class="stat-label">Total Routes</div>
                <div class="stat-value">${totalRoutes}</div>
            </div>
            <div class="stat-card red">
                <div class="stat-icon">👥</div>
                <div class="stat-label">Total Users</div>
                <div class="stat-value">${totalUsers}</div>
            </div>
        </div>

        <div class="row g-3">
            <!-- Quick Actions -->
            <div class="col-12 col-xl-4">
                <div class="panel">
                    <div class="panel-header"><i class="bi bi-lightning-fill" style="color:#f59e0b"></i> Quick Actions</div>
                    <div class="panel-body">
                        <div class="d-flex flex-wrap gap-2">
                            <a href="${pageContext.request.contextPath}/trips/new" class="action-btn"><i class="bi bi-plus-circle-fill"></i>New Trip</a>
                            <a href="${pageContext.request.contextPath}/buses/new" class="action-btn"><i class="bi bi-bus-front-fill"></i>Add Bus</a>
                            <a href="${pageContext.request.contextPath}/routes/new" class="action-btn"><i class="bi bi-signpost-split-fill"></i>Add Route</a>
                            <a href="${pageContext.request.contextPath}/users/new" class="action-btn"><i class="bi bi-person-plus-fill"></i>Add User</a>
                            <a href="${pageContext.request.contextPath}/schedules/new" class="action-btn"><i class="bi bi-calendar-plus-fill"></i>Add Schedule</a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Live Trips -->
            <div class="col-12 col-xl-8">
                <div class="panel">
                    <div class="panel-header">
                        <span style="width:8px;height:8px;border-radius:50%;background:#22c55e;display:inline-block;animation:pulse2 1.4s infinite"></span>
                        Live Trips
                    </div>
                    <table class="live-table">
                        <thead>
                            <tr>
                                <th>Route</th>
                                <th>Driver</th>
                                <th>Bus</th>
                                <th>Status</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty activeTripsList}">
                                <c:forEach var="t" items="${activeTripsList}">
                                <tr>
                                    <td>${t.route.routeName}</td>
                                    <td>${t.driver.name}</td>
                                    <td>${t.bus.registrationNumber}</td>
                                    <td><span class="badge-live">● Live</span></td>
                                    <td><a href="${pageContext.request.contextPath}/tracking/view?tripId=${t.tripId}" class="btn-track" target="_blank"><i class="bi bi-geo-alt-fill"></i> Track</a></td>
                                </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr class="empty-row"><td colspan="5">No active trips right now</td></tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<style>
@keyframes pulse2 {
    0%,100%{box-shadow:0 0 0 0 rgba(34,197,94,.5)}
    50%{box-shadow:0 0 0 5px rgba(34,197,94,0)}
}
</style>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

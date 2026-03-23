import { Shield, Target, TrendingUp, ChevronRight, PlayCircle, Sun, Moon } from 'lucide-react';
import { useState, useEffect } from 'react';
import cattleHero from '../assets/premium_cattle.png';

interface LandingPageProps {
    onGetStarted: () => void;
}

const LandingPage: React.FC<LandingPageProps> = ({ onGetStarted }) => {
    const [isDarkMode, setIsDarkMode] = useState(true);

    useEffect(() => {
        const savedTheme = localStorage.getItem('theme');
        if (savedTheme === 'light') {
            setIsDarkMode(false);
            document.body.classList.add('light-mode');
        }
    }, []);

    const toggleTheme = () => {
        const newMode = !isDarkMode;
        setIsDarkMode(newMode);
        if (newMode) {
            document.body.classList.remove('light-mode');
            localStorage.setItem('theme', 'dark');
        } else {
            document.body.classList.add('light-mode');
            localStorage.setItem('theme', 'light');
        }
    };

    return (
        <div className="min-h-screen">
            {/* Navigation */}
            <nav className="glass" style={{ position: 'fixed', top: 0, width: '100%', zIndex: 100, padding: '1rem 0' }}>
                <div className="container" style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                    <div className="flex items-center gap-2">
                        <div style={{ width: '40px', height: '40px', borderRadius: '10px', background: 'var(--secondary)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                            <Shield size={24} color="white" />
                        </div>
                        <span className="font-outfit" style={{ fontSize: '1.5rem', fontWeight: 700, letterSpacing: '-0.5px' }}>BSAI <span style={{ color: 'var(--primary)' }}>Vision</span></span>
                    </div>

                    <div style={{ display: 'flex', alignItems: 'center', gap: '1.5rem' }}>
                        <a href="#features" className="btn-outline" style={{ border: 'none', padding: '0.5rem', fontSize: '0.95rem', color: 'var(--text-dim)' }}>Features</a>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                            <button
                                onClick={toggleTheme}
                                className="glass"
                                style={{
                                    width: '42px',
                                    height: '42px',
                                    border: '1px solid var(--glass-border)',
                                    borderRadius: '12px',
                                    cursor: 'pointer',
                                    color: 'var(--text)',
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
                                    background: 'var(--glass-bg)',
                                    backdropFilter: 'blur(10px)',
                                    boxShadow: 'var(--card-shadow)',
                                    padding: 0
                                }}
                                title={isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode"}
                                onMouseOver={(e) => {
                                    e.currentTarget.style.transform = 'translateY(-2px)';
                                    e.currentTarget.style.borderColor = 'var(--secondary)';
                                    e.currentTarget.style.boxShadow = '0 10px 20px -10px var(--secondary)';
                                }}
                                onMouseOut={(e) => {
                                    e.currentTarget.style.transform = 'translateY(0)';
                                    e.currentTarget.style.borderColor = 'var(--glass-border)';
                                    e.currentTarget.style.boxShadow = 'var(--card-shadow)';
                                }}
                            >
                                {isDarkMode ? <Sun size={20} /> : <Moon size={20} />}
                            </button>
                            <button
                                onClick={onGetStarted}
                                className="btn-premium"
                                style={{
                                    padding: '0.7rem 1.8rem',
                                    borderRadius: '12px',
                                    fontSize: '0.95rem',
                                    letterSpacing: '0.5px'
                                }}
                            >
                                Login
                            </button>
                        </div>
                    </div>
                </div>
            </nav>

            {/* Hero Section */}
            < section style={{ paddingTop: '10rem', paddingBottom: '6rem', position: 'relative', overflow: 'hidden' }}>
                <div style={{ position: 'absolute', top: '-10%', right: '-5%', width: '40%', height: '40%', borderRadius: '50%', background: 'radial-gradient(circle, rgba(99, 102, 241, 0.15) 0%, transparent 70%)', filter: 'blur(50px)' }}></div>

                <div className="container">
                    <div style={{ display: 'grid', gridTemplateColumns: 'minmax(0, 1.2fr) minmax(0, 1fr)', gap: '4rem', alignItems: 'center' }}>
                        <div className="animate-fade-in">
                            <h1 style={{ fontSize: '4rem', lineHeight: 1.1, marginBottom: '1.5rem', fontWeight: 700 }}>
                                Revolutionizing <br />
                                <span className="gradient-text">Cattle Farming</span> <br />
                                with AI Precision.
                            </h1>
                            <p style={{ fontSize: '1.15rem', color: 'var(--text-dim)', marginBottom: '2.5rem', maxWidth: '550px' }}>
                                Identify breeds with 99% accuracy, track milk yields, and manage herd health using our state-of-the-art computer vision system.
                            </p>
                            <div className="flex gap-4">
                                <button onClick={onGetStarted} className="btn-premium" style={{ fontSize: '1.1rem', gap: '0.5rem' }}>
                                    Get Started <ChevronRight size={20} />
                                </button>
                            </div>
                        </div>

                        <div className="animate-fade-in delay-200" style={{ position: 'relative' }}>
                            <div className="glass-card" style={{ padding: '0.5rem', background: 'rgba(255, 255, 255, 0.02)', borderRadius: '2rem', display: 'flex', alignItems: 'center', justifyContent: 'center', overflow: 'hidden' }}>
                                <div style={{ width: '100%', maxWidth: '500px', aspectRatio: '1', position: 'relative', borderRadius: '1.5rem', overflow: 'hidden' }}>
                                    <img src={cattleHero} alt="AI Scanning Cattle" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                    <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(to bottom, transparent 0%, rgba(10, 15, 30, 0.4) 100%)' }}></div>

                                    {/* Digital Scanning Overlay */}
                                    <div className="animate-scan" style={{ position: 'absolute', width: '100%', height: '3px', background: 'var(--primary)', top: '10%', left: 0, boxShadow: '0 0 20px var(--primary)', zIndex: 10 }}></div>

                                    <div className="glass" style={{ position: 'absolute', bottom: '1.5rem', left: '50%', transform: 'translateX(-50%)', padding: '0.75rem 1.5rem', borderRadius: '1rem', textAlign: 'center', width: '85%', backdropFilter: 'blur(12px)' }}>
                                        <div className="flex items-center justify-center gap-2 mb-1">
                                            <div style={{ width: '8px', height: '8px', borderRadius: '50%', background: 'var(--primary)', animation: 'pulse 1.5s infinite' }}></div>
                                            <p className="font-outfit" style={{ fontSize: '0.75rem', color: 'var(--text-dim)', textTransform: 'uppercase', letterSpacing: '1px' }}>Live AI Vision</p>
                                        </div>
                                        <p className="font-outfit" style={{ fontSize: '1.1rem', fontWeight: 600 }}>Breeding Info: Murrah buffalo (99.4%)</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section >

            {/* Features Grid */}
            < section id="features" style={{ padding: '6rem 0', background: 'rgba(0,0,0,0.2)' }}>
                <div className="container">
                    <div style={{ textAlign: 'center', marginBottom: '4rem' }}>
                        <h2 className="font-outfit" style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>Smart Herd Intelligence</h2>
                        <p style={{ color: 'var(--text-dim)', maxWidth: '600px', margin: '0 auto' }}>Leveraging advanced YOLO models to provide real-time livestock management and reporting.</p>
                    </div>

                    <div className="stat-grid">
                        {[
                            { icon: Target, title: '99% Accuracy', desc: 'Industry-leading deep learning models for precise breed identification.', color: 'var(--primary)' },
                            { icon: TrendingUp, title: 'Yield Analytics', desc: 'Predict milk yield and fat content based on breed metadata.', color: 'var(--secondary)' },
                            { icon: Shield, title: 'BPA Verified', desc: 'Government-compliant reporting and historical tracking system.', color: '#f59e0b' }
                        ].map((f, i) => (
                            <div key={i} className="glass-card" style={{ textAlign: 'center' }}>
                                <div style={{ width: '64px', height: '64px', borderRadius: '1rem', background: `rgba(${f.color === 'var(--primary)' ? '16, 185, 129' : '99, 102, 241'}, 0.1)`, display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 1.5rem', color: f.color }}>
                                    <f.icon size={32} />
                                </div>
                                <h3 style={{ marginBottom: '1rem' }}>{f.title}</h3>
                                <p style={{ color: 'var(--text-dim)', fontSize: '0.95rem' }}>{f.desc}</p>
                            </div>
                        ))}
                    </div>
                </div>
            </section >

            {/* Footer */}
            < footer style={{ padding: '4rem 0', borderTop: '1px solid var(--glass-border)' }}>
                <div className="container flex justify-between items-center">
                    <p style={{ color: 'var(--text-dim)' }}>© 2026 BSAI Infrastructure. Built for Precision.</p>
                    <div className="flex gap-4">
                        <a href="#" className="btn-outline" style={{ border: 'none', fontSize: '0.8rem' }}>Privacy Policy</a>
                        <a href="#" className="btn-outline" style={{ border: 'none', fontSize: '0.8rem' }}>Terms of Service</a>
                    </div>
                </div>
            </footer >
        </div >
    );
};

export default LandingPage;

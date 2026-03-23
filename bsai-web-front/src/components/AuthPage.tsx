import React, { useState, useEffect } from 'react';
import { Mail, Lock, User, Phone, ArrowLeft, ArrowRight, KeyRound, Eye, EyeOff } from 'lucide-react';
import { authApi } from '../services/api';
import cow3d from '../assets/cow_3d.png';
import robot3d from '../assets/robot_3d.png';
import shield3d from '../assets/shield_3d.png';

interface AuthPageProps {
    onBack: () => void;
    onLoginSuccess: (role: 'farmer' | 'bpa') => void;
}

const AuthPage: React.FC<AuthPageProps> = ({ onBack, onLoginSuccess }) => {
    const [isLogin, setIsLogin] = useState(true);
    const [isVerifying, setIsVerifying] = useState(false);
    const [role, setRole] = useState<'farmer' | 'bpa'>('farmer');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const [otpCode, setOtpCode] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [formData, setFormData] = useState({
        email: '',
        password: '',
        full_name: '',
        phone_number: '',
    });

    // Auto-detect role based on email prefix
    useEffect(() => {
        if (formData.email.trim().toUpperCase().startsWith('BPA-')) {
            setRole('bpa');
        } else {
            setRole('farmer');
        }
    }, [formData.email]);

    const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
        setError('');
    };

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError('');
        try {
            const res = await authApi.login({
                email: formData.email,
                password: formData.password
            });
            localStorage.setItem('token', res.data.access_token);
            onLoginSuccess(role);
        } catch (err: any) {
            setError(err.response?.data?.detail || 'Login failed. Please check your credentials.');
        } finally {
            setLoading(false);
        }
    };

    const handleRegister = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError('');
        try {
            await authApi.register({
                ...formData,
                email: formData.email
            });
            setIsVerifying(true);
        } catch (err: any) {
            setError(err.response?.data?.detail || 'Registration failed.');
        } finally {
            setLoading(false);
        }
    };

    const handleVerifyOtp = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError('');
        try {
            await authApi.verifyOtp({
                email: formData.email,
                otp_code: otpCode
            });
            setIsLogin(true);
            setIsVerifying(false);
            alert('Verification successful! Please login.');
        } catch (err: any) {
            setError(err.response?.data?.detail || 'Invalid OTP.');
        } finally {
            setLoading(false);
        }
    };

    if (isVerifying) {
        return (
            <div className="min-h-screen flex items-center justify-center p-6 bg-[#0a0f1e]">
                <div className="glass-card animate-fade-in" style={{ width: '100%', maxWidth: '400px', textAlign: 'center' }}>
                    <KeyRound size={48} color="var(--primary)" style={{ margin: '0 auto 1.5rem' }} />
                    <h2 className="font-outfit" style={{ marginBottom: '1rem' }}>Verify Email</h2>
                    <p style={{ color: 'var(--text-dim)', marginBottom: '2rem' }}>Enter the 6-digit OTP sent to {formData.email}</p>

                    <form onSubmit={handleVerifyOtp} className="flex flex-col gap-4">
                        <input
                            type="text"
                            placeholder="Digit OTP"
                            className="glass-input"
                            style={{ textAlign: 'center', fontSize: '1.5rem', letterSpacing: '0.5rem' }}
                            value={otpCode}
                            onChange={(e) => setOtpCode(e.target.value)}
                            maxLength={6}
                            required
                        />
                        {error && <p style={{ color: '#ef4444', fontSize: '0.85rem' }}>{error}</p>}
                        <button type="submit" className="btn-premium" disabled={loading} style={{ width: '100%' }}>
                            {loading ? 'Verifying...' : 'Verify & Continue'}
                        </button>
                    </form>
                    <button onClick={() => setIsVerifying(false)} className="btn-outline" style={{ marginTop: '1rem', border: 'none', width: '100%' }}>
                        Back to Signup
                    </button>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen flex bg-[#0a0f1e]" style={{ position: 'relative', overflow: 'hidden' }}>
            {/* LEFT SIDE: Visuals (Floating Characters) */}
            <div className="hide-mobile" style={{
                flex: '1.2',
                background: 'rgba(0,0,0,0.3)',
                borderRight: '1px solid var(--glass-border)',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                position: 'relative',
                overflow: 'hidden'
            }}>
                <div style={{ position: 'absolute', inset: 0, backgroundImage: 'radial-gradient(var(--glass-border) 1px, transparent 1px)', backgroundSize: '40px 40px', opacity: 0.3 }}></div>

                {/* Floating 3D Characters */}
                <div style={{ position: 'relative', width: '100%', height: '100%', pointerEvents: 'none' }}>
                    <img
                        src={cow3d}
                        alt="Cow Char"
                        style={{
                            position: 'absolute', top: '25%', left: '20%', width: '180px',
                            filter: 'drop-shadow(0 0 30px rgba(99,102,241,0.4))',
                            animation: 'float 6s ease-in-out infinite'
                        }}
                    />
                    <img
                        src={robot3d}
                        alt="Robot Char"
                        style={{
                            position: 'absolute', bottom: '25%', left: '45%', width: '160px',
                            filter: 'drop-shadow(0 0 30px rgba(16,185,129,0.4))',
                            animation: 'float 8s ease-in-out infinite alternate'
                        }}
                    />
                    <img
                        src={shield3d}
                        alt="Shield Char"
                        style={{
                            position: 'absolute', top: '15%', right: '15%', width: '140px',
                            filter: 'drop-shadow(0 0 20px rgba(245,158,11,0.3))',
                            animation: 'float 7s ease-in-out infinite reverse'
                        }}
                    />
                </div>

                <div style={{ position: 'absolute', bottom: '10%', left: '10%', right: '10%', textAlign: 'center', zIndex: 5 }}>
                    <h3 className="font-outfit" style={{ fontSize: '2rem', marginBottom: '1rem' }}>
                        Modern <span className="gradient-text">Herd Intelligence</span>
                    </h3>
                    <p style={{ color: 'var(--text-dim)', fontSize: '0.95rem', lineHeight: 1.6, maxWidth: '400px', margin: '0 auto' }}>
                        Join the future of livestock management with real-time AI analytics and seamless multi-role access.
                    </p>
                </div>
            </div>

            {/* RIGHT SIDE: Dark Glass Form */}
            <div style={{ flex: '1', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '2rem', zIndex: 10 }}>
                <div className="glass-card animate-fade-in" style={{ width: '100%', maxWidth: '480px', padding: '3rem', position: 'relative' }}>

                    <div style={{
                        position: 'absolute', top: '1.5rem', right: '1.5rem',
                        display: 'flex', alignItems: 'center', gap: '0.5rem',
                        padding: '0.4rem 0.8rem', borderRadius: '2rem',
                        background: role === 'bpa' ? 'rgba(16, 185, 129, 0.1)' : 'rgba(99, 102, 241, 0.1)',
                        border: `1px solid ${role === 'bpa' ? 'var(--primary)' : 'var(--secondary)'}`,
                        transition: 'all 0.5s ease'
                    }}>
                        <span style={{ fontSize: '0.7rem', fontWeight: 700, color: role === 'bpa' ? 'var(--primary)' : 'var(--secondary)', textTransform: 'uppercase' }}>
                            {role === 'bpa' ? 'BPA Officer' : 'Farmer Portal'}
                        </span>
                    </div>

                    <button onClick={onBack} className="btn-outline" style={{ border: 'none', padding: '0.5rem', marginBottom: '2rem', marginLeft: '-1rem', color: 'var(--text-dim)' }}>
                        <ArrowLeft size={20} /> Back
                    </button>

                    <div style={{ marginBottom: '2.5rem' }}>
                        <h2 className="font-outfit" style={{ fontSize: '2.5rem', marginBottom: '0.5rem' }}>{isLogin ? 'Welcome Back' : 'Join BSAI'}</h2>
                        <p style={{ color: 'var(--text-dim)' }}>{isLogin ? 'Enter your details to manage your herd.' : 'Create an account to start using AI vision.'}</p>
                    </div>

                    <form onSubmit={isLogin ? handleLogin : handleRegister} className="flex flex-col gap-5">
                        {!isLogin && (
                            <div style={{ position: 'relative' }}>
                                <User size={20} style={{ position: 'absolute', left: '1rem', top: '1rem', color: 'var(--text-dim)' }} />
                                <input
                                    name="full_name" type="text" placeholder="Full Name" className="glass-input" style={{ paddingLeft: '3rem' }}
                                    value={formData.full_name} onChange={handleInputChange} required
                                />
                            </div>
                        )}

                        <div style={{ position: 'relative' }}>
                            <Mail size={20} style={{ position: 'absolute', left: '1rem', top: '1rem', color: 'var(--text-dim)' }} />
                            <input
                                name="email" type="email" placeholder="Email Address" className="glass-input" style={{ paddingLeft: '3rem' }}
                                value={formData.email} onChange={handleInputChange} required
                            />
                        </div>

                        {!isLogin && (
                            <div style={{ position: 'relative' }}>
                                <Phone size={20} style={{ position: 'absolute', left: '1rem', top: '1rem', color: 'var(--text-dim)' }} />
                                <input
                                    name="phone_number" type="tel" placeholder="Phone Number" className="glass-input" style={{ paddingLeft: '3rem' }}
                                    value={formData.phone_number} onChange={handleInputChange}
                                />
                            </div>
                        )}

                        <div style={{ position: 'relative' }}>
                            <Lock size={20} style={{ position: 'absolute', left: '1rem', top: '1rem', color: 'var(--text-dim)' }} />
                            <input
                                name="password" type={showPassword ? "text" : "password"} placeholder="Password" className="glass-input" style={{ paddingLeft: '3rem', paddingRight: '3rem' }}
                                value={formData.password} onChange={handleInputChange} required
                            />
                            <button
                                type="button"
                                onClick={() => setShowPassword(!showPassword)}
                                style={{ position: 'absolute', right: '1rem', top: '1rem', background: 'none', border: 'none', color: 'var(--text-dim)', cursor: 'pointer' }}
                            >
                                {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                            </button>
                        </div>

                        {error && <p style={{ color: '#ef4444', fontSize: '0.85rem', textAlign: 'center' }}>{error}</p>}

                        <button type="submit" className="btn-premium" disabled={loading} style={{
                            padding: '1rem', marginTop: '1rem',
                            background: role === 'bpa' ? 'linear-gradient(135deg, var(--primary), #059669)' : 'linear-gradient(135deg, var(--secondary), #4f46e5)',
                            transition: 'all 0.5s ease'
                        }}>
                            {loading ? 'Processing...' : (isLogin ? 'Sign In' : 'Create Account')} <ArrowRight size={20} style={{ marginLeft: 'auto' }} />
                        </button>
                    </form>

                    <p style={{ textAlign: 'center', marginTop: '2rem', color: 'var(--text-dim)', fontSize: '0.95rem' }}>
                        {isLogin ? "Don't have an account?" : "Already have an account?"} {' '}
                        <button onClick={() => setIsLogin(!isLogin)} style={{ background: 'none', border: 'none', color: role === 'bpa' ? 'var(--primary)' : 'var(--secondary)', fontWeight: 600, cursor: 'pointer', transition: 'color 0.5s ease' }}>
                            {isLogin ? 'Sign Up' : 'Log In'}
                        </button>
                    </p>
                </div>
            </div>

            <style>{`
                @keyframes float {
                    0%, 100% { transform: translateY(0) rotate(0deg); }
                    50% { transform: translateY(-20px) rotate(2deg); }
                }
                @media (max-width: 900px) {
                    .hide-mobile {
                        display: none !important;
                    }
                }
            `}</style>
        </div>
    );
};

export default AuthPage;

import { useState, useEffect } from 'react';
import {
    Shield, BarChart3, Users, Settings, LogOut,
    Bell, MapPin, Plus, Camera,
    AlertCircle, Activity
} from 'lucide-react';
// import {
//     BarChart, Bar, XAxis, YAxis, Tooltip,
//     ResponsiveContainer, CartesianGrid
// } from 'recharts';
import { bpaApi, farmerApi } from '../services/api';
import NotificationCenter from './NotificationCenter';

interface BPADashboardProps {
    onLogout: () => void;
}

const BPADashboard: React.FC<BPADashboardProps> = ({ onLogout }) => {
    const [activeTab, setActiveTab] = useState('overview');
    const [stats, setStats] = useState<any>(null);
    const [farmers, setFarmers] = useState<any[]>([]);
    const [detections, setDetections] = useState<any[]>([]);
    const [userProfile, setUserProfile] = useState<any>(null);
    const [showNotifications, setShowNotifications] = useState(false);
    const [isUpdating, setIsUpdating] = useState(false);
    const [profileFormData, setProfileFormData] = useState({
        full_name: '',
        phone_number: '',
        email: ''
    });

    // AI Scanner State
    const [isScanning, setIsScanning] = useState(false);
    const [scanResult, setScanResult] = useState<any>(null);
    const [selectedFile, setSelectedFile] = useState<File | null>(null);
    const [earTag, setEarTag] = useState('');

    // Registration State
    const [regFormData, setRegFormData] = useState({
        ear_tag_number: '',
        animal_name: '',
        species: 'Cattle',
        sex: 'Female',
        breed: 'Sahiwal',
        owner_name: '',
        address: '',
        village: '',
        district: '',
        state: ''
    });

    useEffect(() => {
        fetchBPAData();
    }, []);

    const fetchBPAData = async () => {
        try {
            const [statsRes, farmersRes, detRes, profileRes] = await Promise.all([
                bpaApi.getStats(),
                bpaApi.getDistrictFarmers(),
                bpaApi.getAllDetections(),
                farmerApi.getProfile()
            ]);
            setStats(statsRes.data);
            setFarmers(farmersRes.data);
            setDetections(detRes.data);
            setUserProfile(profileRes.data);

            // Pre-fill profile form
            setProfileFormData({
                full_name: profileRes.data.full_name || '',
                phone_number: profileRes.data.phone_number || '',
                email: profileRes.data.email || ''
            });
        } catch (error) {
            console.error('Failed to fetch BPA data:', error);
        }
    };

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files && e.target.files[0]) {
            setSelectedFile(e.target.files[0]);
            setScanResult(null);
        }
    };

    const handleScan = async () => {
        if (!selectedFile) return;
        setIsScanning(true);
        const formData = new FormData();
        formData.append('file', selectedFile);
        if (earTag) formData.append('ear_tag', earTag);

        try {
            const response = await farmerApi.predictAnimal(formData);
            setScanResult(response.data);

            // Only refresh if not rejected
            if (!response.data.not_cattle) {
                fetchBPAData();
            }
        } catch (error) {
            console.error('Scan failed:', error);
            alert('AI Scan failed.');
        } finally {
            setIsScanning(false);
        }
    };

    const startRegistrationFromScan = () => {
        if (!scanResult || scanResult.not_cattle) return;

        setRegFormData({
            ...regFormData,
            breed: scanResult.breed_name,
            ear_tag_number: earTag || '',
        });

        setActiveTab('register');
    };

    const handleRegister = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            await bpaApi.registerAnimal(regFormData);
            alert('Animal registered successfully!');
            setActiveTab('overview');
            fetchBPAData();
        } catch (error: any) {
            alert(error.response?.data?.detail || 'Registration failed');
        }
    };

    const handlePhotoUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files && e.target.files[0]) {
            const formData = new FormData();
            formData.append('file', e.target.files[0]);
            setIsUpdating(true);
            try {
                const response = await farmerApi.uploadProfilePhoto(formData);
                setUserProfile(response.data);
                alert('Profile photo updated!');
            } catch (error: any) {
                alert('Failed to upload photo');
            } finally {
                setIsUpdating(false);
            }
        }
    };

    const handleProfileUpdate = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsUpdating(true);
        try {
            const response = await farmerApi.updateProfile(profileFormData);
            setUserProfile(response.data);
            alert('Official profile updated!');
        } catch (error: any) {
            alert('Failed to update credentials.');
        } finally {
            setIsUpdating(false);
        }
    };

    return (
        <div style={{ display: 'flex', minHeight: '100vh', background: 'var(--background)' }}>
            {/* Sidebar */}
            <aside className="sidebar">
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '3rem' }}>
                    <div style={{ width: '32px', height: '32px', borderRadius: '8px', background: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Shield size={18} color="white" />
                    </div>
                    <span className="font-outfit" style={{ fontSize: '1.25rem', fontWeight: 700 }}>BSAI <span style={{ color: 'var(--primary)' }}>Officer Portal</span></span>
                </div>

                <nav style={{ flex: 1 }}>
                    {[
                        { id: 'overview', icon: BarChart3, label: 'Command Hub' },
                        { id: 'scan', icon: Camera, label: 'Official AI Scan' },
                        { id: 'register', icon: Plus, label: 'New Registration' },
                        { id: 'farmers', icon: Users, label: 'District Registry' },
                        { id: 'logs', icon: Activity, label: 'Security Protocols' },
                        { id: 'settings', icon: Settings, label: 'Configuration' }
                    ].map((item) => (
                        <button
                            key={item.id}
                            onClick={() => setActiveTab(item.id)}
                            className={`nav-item ${activeTab === item.id ? 'active' : ''}`}
                            style={{ width: '100%', border: 'none', background: 'none', cursor: 'pointer', textAlign: 'left' }}
                        >
                            <item.icon size={20} /> {item.label}
                        </button>
                    ))}
                </nav>

                <button onClick={onLogout} className="nav-item" style={{ width: '100%', border: 'none', background: 'none', cursor: 'pointer', textAlign: 'left', marginTop: 'auto', color: '#ef4444' }}>
                    <LogOut size={20} /> De-authorize
                </button>
            </aside>

            {/* Main Content */}
            <main className="main-content">
                <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '3rem' }}>
                    <div>
                        <h1 className="font-outfit" style={{ fontSize: '2rem' }}>State Command Center</h1>
                        <p style={{ color: 'var(--text-dim)' }}>Authorized BPA Regional Oversight & Intelligence.</p>
                    </div>

                    <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
                        <button
                            onClick={() => setShowNotifications(!showNotifications)}
                            style={{ width: '45px', height: '45px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--glass-bg)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: showNotifications ? 'var(--primary)' : 'var(--text-dim)', cursor: 'pointer' }}
                        >
                            <Bell size={20} />
                        </button>
                        <NotificationCenter isOpen={showNotifications} onClose={() => setShowNotifications(false)} />

                        <div style={{ width: '45px', height: '45px', borderRadius: '12px', overflow: 'hidden', border: '1px solid var(--primary)' }}>
                            <img src={userProfile?.profile_photo ? `http://localhost:8000/${userProfile.profile_photo}` : `https://api.dicebear.com/7.x/avataaars/svg?seed=${userProfile?.full_name || 'BPA'}`} alt="Profile" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                        </div>
                    </div>
                </header>

                {activeTab === 'overview' && (
                    <div className="animate-fade-in">
                        <div className="stat-grid">
                            <div className="glass-card">
                                <div style={{ color: 'var(--primary)', marginBottom: '0.5rem', fontSize: '0.85rem' }}>TOTAL ANIMALS</div>
                                <div style={{ fontSize: '2.5rem', fontWeight: 700 }}>{stats?.total_animals || detections.length}</div>
                                <div style={{ color: 'var(--text-dim)', fontSize: '0.75rem', marginTop: '0.5rem' }}>Across district records</div>
                            </div>
                            <div className="glass-card">
                                <div style={{ color: 'var(--secondary)', marginBottom: '0.5rem', fontSize: '0.85rem' }}>REGISTERED FARMERS</div>
                                <div style={{ fontSize: '2.5rem', fontWeight: 700 }}>{farmers.length}</div>
                                <div style={{ color: 'var(--text-dim)', fontSize: '0.75rem', marginTop: '0.5rem' }}>Active portal accounts</div>
                            </div>
                            <div className="glass-card">
                                <div style={{ color: '#f59e0b', marginBottom: '0.5rem', fontSize: '0.85rem' }}>PENDING TASKS</div>
                                <div style={{ fontSize: '2.5rem', fontWeight: 700 }}>{stats?.pending_verifications || 0}</div>
                                <div style={{ color: 'var(--text-dim)', fontSize: '0.75rem', marginTop: '0.5rem' }}>Verifications required</div>
                            </div>
                        </div>

                        <div className="glass-card" style={{ padding: '0' }}>
                            <div style={{ padding: '1.5rem', borderBottom: '1px solid var(--glass-border)', display: 'flex', justifyContent: 'space-between' }}>
                                <h3>Global AI Activity (Recent Scans)</h3>
                                <button onClick={() => setActiveTab('logs')} className="btn-outline" style={{ padding: '0.4rem 1rem', fontSize: '0.75rem' }}>View Full Logs</button>
                            </div>
                            <div style={{ overflowX: 'auto' }}>
                                <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                                    <thead>
                                        <tr style={{ textAlign: 'left', background: 'rgba(255,255,255,0.02)' }}>
                                            <th style={{ padding: '1rem' }}>Scan Asset</th>
                                            <th style={{ padding: '1rem' }}>Ear Tag</th>
                                            <th style={{ padding: '1rem' }}>Breed Result</th>
                                            <th style={{ padding: '1rem' }}>Confidence</th>
                                            <th style={{ padding: '1rem' }}>Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {detections.slice(0, 5).map((det, i) => (
                                            <tr key={i} style={{ borderBottom: '1px solid var(--glass-border)' }}>
                                                <td style={{ padding: '0.75rem 1rem' }}>
                                                    <div style={{ width: '50px', height: '50px', borderRadius: '8px', overflow: 'hidden', border: '1px solid var(--glass-border)' }}>
                                                        <img src={`http://localhost:8000/${det.image_path}`} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                                    </div>
                                                </td>
                                                <td style={{ padding: '1rem' }}>{det.animal_ear_tag || 'N/A'}</td>
                                                <td style={{ padding: '1rem' }}>{det.breed_name}</td>
                                                <td style={{ padding: '1rem' }}>{Math.round(det.confidence_score)}%</td>
                                                <td style={{ padding: '1rem' }}>
                                                    <span style={{ fontSize: '0.7rem', padding: '0.2rem 0.6rem', borderRadius: '1rem', background: 'rgba(16, 185, 129, 0.1)', color: 'var(--primary)' }}>VERIFIED</span>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                )}

                {activeTab === 'scan' && (
                    <div className="animate-fade-in" style={{ maxWidth: '800px', margin: '0 auto' }}>
                        <div style={{ textAlign: 'center', marginBottom: '3rem' }}>
                            <h2 className="font-outfit" style={{ fontSize: '2.2rem' }}>Official AI Inspection</h2>
                            <p style={{ color: 'var(--text-dim)' }}>Use this portal for authorized breed verification and identification.</p>
                        </div>

                        <div className="glass-card" style={{ padding: '3rem', borderStyle: 'dashed', borderWidth: '2px', borderColor: 'var(--glass-border)' }}>
                            {!selectedFile ? (
                                <div style={{ textAlign: 'center' }}>
                                    <div style={{ width: '80px', height: '80px', borderRadius: '50%', background: 'rgba(16, 185, 129, 0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 1.5rem' }}>
                                        <Camera size={40} color="var(--primary)" />
                                    </div>
                                    <h3 style={{ marginBottom: '1rem' }}>Secure Asset Upload</h3>
                                    <input type="file" id="bpa-upload" style={{ display: 'none' }} onChange={handleFileChange} accept="image/*" />
                                    <button className="btn-premium" onClick={() => document.getElementById('bpa-upload')?.click()}>Select Image</button>
                                </div>
                            ) : (
                                <div>
                                    <div style={{ position: 'relative', borderRadius: '1rem', overflow: 'hidden', marginBottom: '2rem', maxHeight: '400px', background: 'rgba(0,0,0,0.2)' }}>
                                        <img src={URL.createObjectURL(selectedFile)} style={{ width: '100%', height: 'auto', maxHeight: '400px', objectFit: 'contain' }} />
                                        {isScanning && (
                                            <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.7)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexDirection: 'column', gap: '1rem' }}>
                                                <div className="loader"></div>
                                                <p className="font-outfit" style={{ color: 'var(--primary)', letterSpacing: '4px' }}>ANALYZING GENOME...</p>
                                            </div>
                                        )}
                                    </div>

                                    <div style={{ marginBottom: '2rem' }}>
                                        <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.85rem', color: 'var(--text-dim)' }}>ASSOCIATED EAR TAG (OPTIONAL)</label>
                                        <input
                                            type="text" className="glass-input" placeholder="Enter Tag ID for association..."
                                            value={earTag} onChange={(e) => setEarTag(e.target.value)}
                                        />
                                    </div>

                                    <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center' }}>
                                        <button className="btn-outline" onClick={() => setSelectedFile(null)}>Reset</button>
                                        <button className="btn-premium" onClick={handleScan} disabled={isScanning}>
                                            Execute AI Analysis
                                        </button>
                                    </div>
                                </div>
                            )}
                        </div>

                        {scanResult && !scanResult.not_cattle && (
                            <div className="glass-card animate-scale-in" style={{ marginTop: '2rem', border: '1px solid var(--primary)' }}>
                                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '2rem', textAlign: 'center' }}>
                                    <div>
                                        <p style={{ color: 'var(--text-dim)', fontSize: '0.7rem' }}>BREED TYPE</p>
                                        <h3 style={{ color: 'var(--primary)' }}>{scanResult.breed_name}</h3>
                                    </div>
                                    <div>
                                        <p style={{ color: 'var(--text-dim)', fontSize: '0.7rem' }}>CONFIDENCE</p>
                                        <h3>{Math.round(scanResult.confidence_score)}%</h3>
                                    </div>
                                    <div>
                                        <p style={{ color: 'var(--text-dim)', fontSize: '0.7rem' }}>EST. YIELD</p>
                                        <h3>{scanResult.yield_estimate}L/Day</h3>
                                    </div>
                                </div>
                                <div style={{ marginTop: '2rem', textAlign: 'center' }}>
                                    <button className="btn-premium" onClick={startRegistrationFromScan} style={{ width: '100%' }}>
                                        <Plus size={18} style={{ marginRight: '0.5rem' }} /> Authorize Registration
                                    </button>
                                </div>
                            </div>
                        )}

                        {scanResult && (scanResult.not_cattle || scanResult.breed_name === "Unidentified") && (
                            <div className="glass-card animate-scale-in" style={{ marginTop: '2rem', border: '1px solid #ef4444', background: 'rgba(239, 68, 68, 0.05)' }}>
                                <div style={{ display: 'flex', gap: '1.5rem', alignItems: 'center' }}>
                                    <div style={{ width: '60px', height: '60px', borderRadius: '50%', background: 'rgba(239, 68, 68, 0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                                        <AlertCircle size={32} color="#ef4444" />
                                    </div>
                                    <div>
                                        <h3 style={{ color: '#ef4444', marginBottom: '0.5rem' }}>Animal Rejected</h3>
                                        <p style={{ color: 'var(--text-dim)', fontSize: '0.9rem', lineHeight: 1.6 }}>
                                            {scanResult.message || "This image does not contain identifiable Cattle or Buffalo breeds supported by BreedSureAI."}
                                        </p>
                                    </div>
                                </div>
                                <button
                                    className="btn-outline"
                                    onClick={() => { setSelectedFile(null); setScanResult(null); }}
                                    style={{ width: '100%', marginTop: '1.5rem', borderColor: 'rgba(239, 68, 68, 0.2)' }}
                                >
                                    Dismiss & Retry
                                </button>
                            </div>
                        )}
                    </div>
                )}

                {activeTab === 'register' && (
                    <div className="animate-fade-in" style={{ maxWidth: '900px', margin: '0 auto' }}>
                        <div style={{ marginBottom: '2.5rem' }}>
                            <h2 className="font-outfit" style={{ fontSize: '2.2rem' }}>Animal Registration</h2>
                            <p style={{ color: 'var(--text-dim)' }}>Formal entry into the official regional database.</p>
                        </div>

                        <form onSubmit={handleRegister} className="glass-card" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>
                            <div className="input-group">
                                <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.85rem' }}>Ear Tag Number</label>
                                <input className="glass-input" required value={regFormData.ear_tag_number} onChange={(e) => setRegFormData({ ...regFormData, ear_tag_number: e.target.value })} />
                            </div>
                            <div className="input-group">
                                <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.85rem' }}>Animal Name</label>
                                <input className="glass-input" required value={regFormData.animal_name} onChange={(e) => setRegFormData({ ...regFormData, animal_name: e.target.value })} />
                            </div>
                            <div className="input-group">
                                <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.85rem' }}>Species</label>
                                <select className="glass-input" value={regFormData.species} onChange={(e) => setRegFormData({ ...regFormData, species: e.target.value })}>
                                    <option value="Cattle">Cattle</option>
                                    <option value="Buffalo">Buffalo</option>
                                </select>
                            </div>
                            <div className="input-group">
                                <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.85rem' }}>Sex</label>
                                <select className="glass-input" value={regFormData.sex} onChange={(e) => setRegFormData({ ...regFormData, sex: e.target.value })}>
                                    <option value="Female">Female</option>
                                    <option value="Male">Male</option>
                                </select>
                            </div>
                            <div className="input-group">
                                <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.85rem' }}>Breed Selection</label>
                                <select className="glass-input" style={{ appearance: 'none' }} value={regFormData.breed} onChange={(e) => setRegFormData({ ...regFormData, breed: e.target.value })}>
                                    <option value="Sahiwal">Sahiwal</option>
                                    <option value="Gir">Gir</option>
                                    <option value="Murrah">Murrah Buffalo</option>
                                    <option value="Holstein Friesian">HF Cow</option>
                                    <option value="Jersey">Jersey</option>
                                    <option value="Pandharpuri">Pandharpuri Buffalo</option>
                                </select>
                            </div>
                            <div className="input-group">
                                <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.85rem' }}>Owner Full Name</label>
                                <input className="glass-input" required value={regFormData.owner_name} onChange={(e) => setRegFormData({ ...regFormData, owner_name: e.target.value })} />
                            </div>
                            <div className="input-group">
                                <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.85rem' }}>Owner Address</label>
                                <input className="glass-input" required value={regFormData.address} onChange={(e) => setRegFormData({ ...regFormData, address: e.target.value })} />
                            </div>
                            <div className="input-group">
                                <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.85rem' }}>Village / Area</label>
                                <input className="glass-input" required value={regFormData.village} onChange={(e) => setRegFormData({ ...regFormData, village: e.target.value })} />
                            </div>
                            <div className="input-group">
                                <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.85rem' }}>District</label>
                                <input className="glass-input" required value={regFormData.district} onChange={(e) => setRegFormData({ ...regFormData, district: e.target.value })} />
                            </div>
                            <div className="input-group">
                                <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.85rem' }}>State</label>
                                <input className="glass-input" required value={regFormData.state} onChange={(e) => setRegFormData({ ...regFormData, state: e.target.value })} />
                            </div>

                            <div style={{ gridColumn: 'span 2', marginTop: '1rem' }}>
                                <button type="submit" className="btn-premium" style={{ width: '100%', padding: '1rem' }}>Authorize Registration</button>
                            </div>
                        </form>
                    </div>
                )}

                {activeTab === 'farmers' && (
                    <div className="animate-fade-in">
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
                            <h2 className="font-outfit" style={{ fontSize: '2rem' }}>District Farmer Directory</h2>
                        </div>
                        <div className="glass-card" style={{ padding: 0 }}>
                            <div style={{ overflowX: 'auto' }}>
                                <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                                    <thead>
                                        <tr style={{ background: 'rgba(255,255,255,0.02)', textAlign: 'left' }}>
                                            <th style={{ padding: '1.25rem' }}>Reference</th>
                                            <th style={{ padding: '1.25rem' }}>Contact</th>
                                            <th style={{ padding: '1.25rem' }}>Location</th>
                                            <th style={{ padding: '1.25rem' }}>Security Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {farmers.map((farmer, i) => (
                                            <tr key={i} style={{ borderBottom: '1px solid var(--glass-border)' }}>
                                                <td style={{ padding: '1.25rem' }}>
                                                    <div style={{ fontWeight: 700 }}>{farmer.full_name}</div>
                                                    <div style={{ fontSize: '0.7rem', color: 'var(--text-dim)' }}>ID: #{farmer.id}</div>
                                                </td>
                                                <td style={{ padding: '1.25rem' }}>
                                                    <div style={{ fontSize: '0.85rem' }}>{farmer.phone_number}</div>
                                                    <div style={{ fontSize: '0.75rem', color: 'var(--text-dim)' }}>{farmer.email}</div>
                                                </td>
                                                <td style={{ padding: '1.25rem' }}>
                                                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', fontSize: '0.85rem' }}>
                                                        <MapPin size={14} color="var(--primary)" />
                                                        {farmer.address || 'District A-1'}
                                                    </div>
                                                </td>
                                                <td style={{ padding: '1.25rem' }}>
                                                    <span style={{ background: 'rgba(16, 185, 129, 0.1)', color: 'var(--primary)', padding: '0.2rem 0.6rem', borderRadius: '1rem', fontSize: '0.7rem', fontWeight: 700 }}>ACTIVE</span>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                )}

                {activeTab === 'logs' && (
                    <div className="animate-fade-in">
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
                            <h2 className="font-outfit" style={{ fontSize: '2rem' }}>Security Protocols & Audit Logs</h2>
                        </div>
                        <div className="glass-card" style={{ padding: 0 }}>
                            <div style={{ padding: '2rem', textAlign: 'center', color: 'var(--text-dim)', opacity: 0.5 }}>
                                <Activity size={60} style={{ margin: '0 auto 1.5rem' }} />
                                <p style={{ fontSize: '1.1rem' }}>Secure Audit trail initialized. No anomalies detected.</p>
                                <p style={{ fontSize: '0.8rem', marginTop: '0.5rem' }}>Full decryption logs available to Regional Administrators only.</p>
                            </div>
                        </div>
                    </div>
                )}

                {activeTab === 'settings' && (
                    <div className="animate-fade-in" style={{ maxWidth: '800px' }}>
                        <h2 className="font-outfit" style={{ fontSize: '2rem', marginBottom: '2rem' }}>Officer Configuration</h2>
                        <div className="glass-card" style={{ padding: '2.5rem' }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '2rem', marginBottom: '3rem' }}>
                                <div style={{ position: 'relative' }}>
                                    <div style={{ width: '120px', height: '120px', borderRadius: '24px', overflow: 'hidden', border: '4px solid var(--primary)' }}>
                                        <img src={userProfile?.profile_photo ? `http://localhost:8000/${userProfile.profile_photo}` : `https://api.dicebear.com/7.x/avataaars/svg?seed=${userProfile?.full_name || 'BPA'}`} alt="Profile Large" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                    </div>
                                    <input type="file" id="bpa-photo-input" style={{ display: 'none' }} onChange={handlePhotoUpload} accept="image/*" />
                                    <button
                                        onClick={() => document.getElementById('bpa-photo-input')?.click()}
                                        disabled={isUpdating}
                                        style={{ position: 'absolute', bottom: '-10px', right: '-10px', width: '40px', height: '40px', borderRadius: '12px', background: 'var(--primary)', color: 'white', border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 4px 12px rgba(0,0,0,0.3)', cursor: 'pointer', opacity: isUpdating ? 0.7 : 1 }}>
                                        <Camera size={18} />
                                    </button>
                                </div>
                                <div>
                                    <h2 style={{ fontSize: '1.75rem', marginBottom: '0.25rem' }}>{userProfile?.full_name}</h2>
                                    <p style={{ color: 'var(--text-dim)' }}>Certified BPA Field Officer</p>
                                    <div style={{ display: 'flex', gap: '0.5rem', marginTop: '1rem' }}>
                                        <span style={{ background: 'rgba(16, 185, 129, 0.1)', color: 'var(--primary)', padding: '0.25rem 0.75rem', borderRadius: '1rem', fontSize: '0.75rem', fontWeight: 700 }}>LEVEL 4 AUTH</span>
                                        <span style={{ background: 'rgba(99, 102, 241, 0.1)', color: 'var(--secondary)', padding: '0.25rem 0.75rem', borderRadius: '1rem', fontSize: '0.75rem', fontWeight: 700 }}>VERIFIED OFFICE</span>
                                    </div>
                                </div>
                            </div>
                            <form onSubmit={handleProfileUpdate} style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem' }}>
                                <div className="input-group">
                                    <label style={{ display: 'block', color: 'var(--text-dim)', fontSize: '0.85rem', marginBottom: '0.75rem' }}>Authorized Name</label>
                                    <input
                                        className="glass-input"
                                        value={profileFormData.full_name}
                                        onChange={(e) => setProfileFormData({ ...profileFormData, full_name: e.target.value })}
                                    />
                                </div>
                                <div className="input-group">
                                    <label style={{ display: 'block', color: 'var(--text-dim)', fontSize: '0.85rem', marginBottom: '0.75rem' }}>Officer ID</label>
                                    <input className="glass-input" readOnly value={`BPA-${userProfile?.id || '...'}`} style={{ opacity: 0.6 }} />
                                </div>
                                <div className="input-group">
                                    <label style={{ display: 'block', color: 'var(--text-dim)', fontSize: '0.85rem', marginBottom: '0.75rem' }}>Contact Protocol</label>
                                    <input
                                        className="glass-input"
                                        value={profileFormData.phone_number}
                                        onChange={(e) => setProfileFormData({ ...profileFormData, phone_number: e.target.value })}
                                    />
                                </div>
                                <div className="input-group">
                                    <button
                                        type="submit"
                                        disabled={isUpdating}
                                        className="btn-premium"
                                        style={{ width: '100%', marginTop: 'auto', opacity: isUpdating ? 0.7 : 1 }}
                                    >
                                        {isUpdating ? 'Re-verifying...' : 'Update Official Profile'}
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                )}
            </main>
        </div>
    );
};

export default BPADashboard;

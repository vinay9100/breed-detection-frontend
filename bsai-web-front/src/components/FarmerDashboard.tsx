import { useState, useEffect } from 'react';
import {
    LayoutDashboard, Camera, History, Scale, Calendar,
    BarChart3, Settings, LogOut, Bell,
    TrendingUp, Phone, Mail, User, Download,
    Droplets, Info, ExternalLink, CheckCircle, AlertCircle, Plus
} from 'lucide-react';
import {
    XAxis, YAxis, Tooltip,
    ResponsiveContainer, AreaChart, Area,
    CartesianGrid
} from 'recharts';
import { farmerApi } from '../services/api';
import NotificationCenter from './NotificationCenter';
import BreedComparison from './BreedComparison';
import Timetable from './Timetable';

const chartData = [
    { name: 'Mon', yield: 40, fat: 3.8 },
    { name: 'Tue', yield: 45, fat: 4.2 },
    { name: 'Wed', yield: 42, fat: 4.0 },
    { name: 'Thu', yield: 48, fat: 4.5 },
    { name: 'Fri', yield: 46, fat: 4.3 },
    { name: 'Sat', yield: 50, fat: 4.6 },
    { name: 'Sun', yield: 44, fat: 4.1 },
];

interface FarmerDashboardProps {
    onLogout: () => void;
}

const FarmerDashboard: React.FC<FarmerDashboardProps> = ({ onLogout }) => {
    const [activeTab, setActiveTab] = useState('dashboard');
    const [isScanning, setIsScanning] = useState(false);
    const [scanResult, setScanResult] = useState<any>(null);
    const [detections, setDetections] = useState<any[]>([]);
    const [registeredAnimals, setRegisteredAnimals] = useState<any[]>([]); // New state
    const [selectedFile, setSelectedFile] = useState<File | null>(null);
    const [earTag, setEarTag] = useState(''); // Added for AI Scan association
    const [userProfile, setUserProfile] = useState<any>(null);
    const [recentActivity, setRecentActivity] = useState<any[]>([]);
    const [showNotifications, setShowNotifications] = useState(false);
    const [isUpdating, setIsUpdating] = useState(false);
    const [profileFormData, setProfileFormData] = useState({
        full_name: '',
        phone_number: '',
        email: ''
    });



    useEffect(() => {
        fetchInitialData();
    }, []);

    const fetchInitialData = async () => {
        try {
            const [profileRes, detectionsRes, activityRes, animalsRes] = await Promise.all([
                farmerApi.getProfile(),
                farmerApi.getDetections(),
                farmerApi.getRecentActivity(),
                farmerApi.getAnimals() // Fetch registered animals
            ]);
            setUserProfile(profileRes.data);
            setDetections(detectionsRes.data);
            setRecentActivity(activityRes.data);
            setRegisteredAnimals(animalsRes.data);

            // Pre-fill profile form
            setProfileFormData({
                full_name: profileRes.data.full_name || '',
                phone_number: profileRes.data.phone_number || '',
                email: profileRes.data.email || ''
            });
        } catch (error) {
            console.error('Failed to fetch dashboard data:', error);
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

            // Only refresh history if it was a successful scan (not rejected)
            if (!response.data.not_cattle) {
                const [detRes, actRes] = await Promise.all([
                    farmerApi.getDetections(),
                    farmerApi.getRecentActivity()
                ]);
                setDetections(detRes.data);
                setRecentActivity(actRes.data);
            }
        } catch (error) {
            console.error('Scan failed:', error);
            alert('AI Scan failed. Please check backend connection.');
        } finally {
            setIsScanning(false);
        }
    };



    const handleProfileUpdate = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsUpdating(true);
        try {
            const response = await farmerApi.updateProfile(profileFormData);
            setUserProfile(response.data);
            alert('Profile updated successfully!');
        } catch (error: any) {
            console.error('Profile update failed:', error);
            alert(error.response?.data?.detail || 'Failed to update profile');
        } finally {
            setIsUpdating(false);
        }
    };

    const handlePhotoUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files && e.target.files[0]) {
            const file = e.target.files[0];
            const formData = new FormData();
            formData.append('file', file);

            setIsUpdating(true);
            try {
                const response = await farmerApi.uploadProfilePhoto(formData);
                setUserProfile(response.data);
                alert('Profile photo updated!');
            } catch (error: any) {
                console.error('Photo upload failed:', error);
                alert(error.response?.data?.detail || 'Failed to upload photo');
            } finally {
                setIsUpdating(false);
            }
        }
    };

    const handleDeleteAccount = async () => {
        if (window.confirm('Are you absolutely sure? This will delete all your data permanently.')) {
            try {
                // Assuming backend has /account DELETE
                await farmerApi.deleteAccount?.() || alert('Backend delete endpoint not implemented in service');
                onLogout();
            } catch (error) {
                alert('Failed to delete account');
            }
        }
    };

    return (
        <div style={{ display: 'flex', minHeight: '100vh', background: 'var(--background)' }}>
            {/* Sidebar */}
            <aside className="sidebar">
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '3rem' }}>
                    <div style={{ width: '32px', height: '32px', borderRadius: '8px', background: 'var(--secondary)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <TrendingUp size={18} color="white" />
                    </div>
                    <span className="font-outfit" style={{ fontSize: '1.25rem', fontWeight: 700 }}>BSAI <span style={{ color: 'var(--primary)' }}>Farmer</span></span>
                </div>

                <nav style={{ flex: 1 }}>
                    {[
                        { id: 'dashboard', icon: LayoutDashboard, label: 'Overview' },
                        { id: 'scan', icon: Camera, label: 'AI Scanner' },
                        { id: 'herd', icon: Scale, label: 'My Herd' }, // Added
                        { id: 'history', icon: History, label: 'Scan History' }, // Renamed from Herd History
                        { id: 'timetable', icon: Calendar, label: 'Care Plan' },
                        { id: 'comparison', icon: Scale, label: 'Comparisons' },
                        { id: 'analytics', icon: BarChart3, label: 'Milk Analytics' },
                        { id: 'settings', icon: Settings, label: 'Profile' }
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
                    <LogOut size={20} /> Sign Out
                </button>
            </aside>

            {/* Main Content */}
            <main className="main-content">
                <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '3rem' }}>
                    <div>
                        <h1 className="font-outfit" style={{ fontSize: '2rem' }}>Welcome, {userProfile?.full_name || 'Farmer'}</h1>
                        <p style={{ color: 'var(--text-dim)' }}>Here is what's happening with your herd today.</p>
                    </div>

                    <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
                        <button
                            onClick={() => setShowNotifications(!showNotifications)}
                            style={{ width: '45px', height: '45px', borderRadius: '12px', border: '1px solid var(--glass-border)', background: 'var(--glass-bg)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: showNotifications ? 'var(--primary)' : 'var(--text-dim)', cursor: 'pointer' }}
                        >
                            <Bell size={20} />
                        </button>
                        <NotificationCenter isOpen={showNotifications} onClose={() => setShowNotifications(false)} />

                        <div style={{ width: '45px', height: '45px', borderRadius: '12px', overflow: 'hidden', border: '1px solid var(--secondary)' }}>
                            <img src={userProfile?.profile_photo ? `http://localhost:8000/${userProfile.profile_photo}` : `https://api.dicebear.com/7.x/avataaars/svg?seed=${userProfile?.full_name || 'Farmer'}`} alt="Profile" style={{ width: '100%', height: '100%' }} />
                        </div>
                    </div>
                </header>

                {activeTab === 'dashboard' && (
                    <div className="animate-fade-in">
                        <div className="stat-grid">
                            <div className="glass-card">
                                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}>
                                    <div style={{ color: 'var(--secondary)' }}>Total Cattle</div>
                                    <Plus size={20} color="var(--text-dim)" />
                                </div>
                                <div style={{ fontSize: '2.5rem', fontWeight: 700 }}>{registeredAnimals.length}</div>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--primary)', marginTop: '0.5rem', fontSize: '0.85rem' }}>
                                    <CheckCircle size={14} /> Registered Herd
                                </div>
                            </div>
                            <div className="glass-card">
                                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}>
                                    <div style={{ color: 'var(--primary)' }}>Avg Monthly Yield</div>
                                    <Droplets size={20} color="var(--text-dim)" />
                                </div>
                                <div style={{ fontSize: '2.5rem', fontWeight: 700 }}>142 L</div>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--primary)', marginTop: '0.5rem', fontSize: '0.85rem' }}>
                                    <TrendingUp size={14} /> 8.4% avg fat
                                </div>
                            </div>
                            <div className="glass-card">
                                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}>
                                    <div style={{ color: '#f59e0b' }}>AI Confidence</div>
                                    <Info size={20} color="var(--text-dim)" />
                                </div>
                                <div style={{ fontSize: '2.5rem', fontWeight: 700 }}>98.2%</div>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--text-dim)', marginTop: '0.5rem', fontSize: '0.85rem' }}>
                                    Precision metrics
                                </div>
                            </div>
                        </div>

                        <div style={{ display: 'grid', gridTemplateColumns: '1.5fr 1fr', gap: '1.5rem' }}>
                            <div className="glass-card" style={{ padding: '1.5rem' }}>
                                <h3 style={{ marginBottom: '1.5rem' }}>Yield Overview</h3>
                                <div style={{ width: '100%', height: '300px' }}>
                                    <ResponsiveContainer width="100%" height="100%">
                                        <AreaChart data={chartData}>
                                            <defs>
                                                <linearGradient id="colorYield" x1="0" y1="0" x2="0" y2="1">
                                                    <stop offset="5%" stopColor="var(--secondary)" stopOpacity={0.1} />
                                                    <stop offset="95%" stopColor="var(--secondary)" stopOpacity={0} />
                                                </linearGradient>
                                            </defs>
                                            <XAxis dataKey="name" stroke="var(--text-dim)" fontSize={12} tickLine={false} axisLine={false} />
                                            <YAxis stroke="var(--text-dim)" fontSize={12} tickLine={false} axisLine={false} />
                                            <Tooltip
                                                contentStyle={{ background: 'var(--background)', border: '1px solid var(--glass-border)', borderRadius: '8px' }}
                                            />
                                            <Area type="monotone" dataKey="yield" stroke="var(--secondary)" fillOpacity={1} fill="url(#colorYield)" />
                                        </AreaChart>
                                    </ResponsiveContainer>
                                </div>
                            </div>

                            <div className="glass-card">
                                <h3 style={{ marginBottom: '1.5rem' }}>Recent Activity</h3>
                                <div className="flex flex-col gap-4">
                                    {recentActivity.slice(0, 3).map((item, i) => (
                                        <div key={i} className="glass" style={{ padding: '1rem', borderRadius: '1rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                            <div>
                                                <div style={{ fontSize: '0.9rem', fontWeight: 600 }}>{item.title}</div>
                                                <div style={{ fontSize: '0.75rem', color: 'var(--text-dim)' }}>{item.subtitle}</div>
                                            </div>
                                            <div style={{ fontSize: '0.75rem', color: 'var(--primary)' }}>{item.time}</div>
                                        </div>
                                    ))}
                                    <button className="btn-outline" onClick={() => setActiveTab('history')} style={{ width: '100%', marginTop: '0.5rem', fontSize: '0.85rem' }}>
                                        View All History <ExternalLink size={14} style={{ marginLeft: '0.5rem' }} />
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                )}



                {activeTab === 'herd' && (
                    <div className="animate-fade-in">
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
                            <h2 className="font-outfit" style={{ fontSize: '2rem' }}>My Registered Herd</h2>
                            <button className="btn-premium" onClick={() => setActiveTab('register')}>
                                <Plus size={16} style={{ marginRight: '0.5rem' }} /> Add New Animal
                            </button>
                        </div>
                        <div className="glass-card" style={{ padding: 0 }}>
                            <div style={{ overflowX: 'auto' }}>
                                <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                                    <thead>
                                        <tr style={{ background: 'rgba(255,255,255,0.02)', textAlign: 'left' }}>
                                            <th style={{ padding: '1.25rem' }}>Animal Identity</th>
                                            <th style={{ padding: '1.25rem' }}>Breed & Gender</th>
                                            <th style={{ padding: '1.25rem' }}>Location</th>
                                            <th style={{ padding: '1.25rem' }}>Last Scanned</th>
                                            <th style={{ padding: '1.25rem' }}>Registration Date</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {registeredAnimals.length > 0 ? registeredAnimals.map((animal, i) => (
                                            <tr key={i} style={{ borderBottom: '1px solid var(--glass-border)' }}>
                                                <td style={{ padding: '1.25rem' }}>
                                                    <div style={{ fontWeight: 700, color: 'var(--primary)' }}>{animal.animal_name}</div>
                                                    <div style={{ fontSize: '0.8rem', color: 'var(--text-dim)' }}>Tag: {animal.ear_tag_number}</div>
                                                </td>
                                                <td style={{ padding: '1.25rem' }}>
                                                    <div style={{ fontSize: '0.9rem' }}>{animal.breed}</div>
                                                    <div style={{ fontSize: '0.75rem', color: 'var(--text-dim)' }}>{animal.sex} | {animal.species}</div>
                                                </td>
                                                <td style={{ padding: '1.25rem' }}>
                                                    <div style={{ fontSize: '0.9rem' }}>{animal.village}, {animal.district}</div>
                                                    <div style={{ fontSize: '0.75rem', color: 'var(--text-dim)' }}>{animal.state}</div>
                                                </td>
                                                <td style={{ padding: '1.25rem' }}>
                                                    {animal.last_image_path ? (
                                                        <div style={{ width: '40px', height: '40px', borderRadius: '8px', overflow: 'hidden', border: '1px solid var(--glass-border)' }}>
                                                            <img src={`http://localhost:8000/${animal.last_image_path}`} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                                        </div>
                                                    ) : (
                                                        <span style={{ fontSize: '0.75rem', color: 'var(--text-dim)' }}>Not scanned yet</span>
                                                    )}
                                                </td>
                                                <td style={{ padding: '1.25rem' }}>
                                                    <div style={{ fontSize: '0.85rem' }}>{new Date(animal.registered_at).toLocaleDateString()}</div>
                                                </td>
                                            </tr>
                                        )) : (
                                            <tr>
                                                <td colSpan={5} style={{ padding: '4rem', textAlign: 'center', color: 'var(--text-dim)' }}>
                                                    <p>You haven't registered any animals yet.</p>
                                                    <button className="btn-outline" style={{ marginTop: '1rem' }} onClick={() => setActiveTab('register')}>Register Your First Animal</button>
                                                </td>
                                            </tr>
                                        )}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                )}

                {activeTab === 'scan' && (
                    <div className="animate-fade-in">
                        <div style={{ textAlign: 'center', marginBottom: '3rem' }}>
                            <h2 className="font-outfit" style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>AI Breed Scanner</h2>
                            <p style={{ color: 'var(--text-dim)' }}>Upload a photo of your cattle for instant breed identification and yield estimation.</p>
                        </div>

                        <div style={{ maxWidth: '800px', margin: '0 auto' }}>
                            <div className="glass-card" style={{ padding: '3rem', borderStyle: 'dashed', borderWidth: '2px', borderColor: 'var(--glass-border)' }}>
                                {!selectedFile ? (
                                    <div style={{ textAlign: 'center' }}>
                                        <div className="pulse" style={{ width: '80px', height: '80px', borderRadius: '50%', background: 'rgba(16, 185, 129, 0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 1.5rem' }}>
                                            <Camera size={40} color="var(--primary)" />
                                        </div>
                                        <h3>Select Cattle Image</h3>
                                        <p style={{ color: 'var(--text-dim)', marginBottom: '2rem' }}>Drag and drop or click to browse files</p>
                                        <input type="file" id="cattle-upload" style={{ display: 'none' }} onChange={handleFileChange} accept="image/*" />
                                        <button className="btn-premium" onClick={() => document.getElementById('cattle-upload')?.click()}>Browse Library</button>
                                    </div>
                                ) : (
                                    <div>
                                        <div style={{ position: 'relative', borderRadius: '1rem', overflow: 'hidden', marginBottom: '2rem', maxHeight: '400px', background: 'rgba(0,0,0,0.2)' }}>
                                            <img src={URL.createObjectURL(selectedFile)} style={{ width: '100%', height: 'auto', maxHeight: '400px', objectFit: 'contain' }} />
                                            {isScanning && (
                                                <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexDirection: 'column', gap: '1.5rem' }}>
                                                    <div className="loader"></div>
                                                    <p className="font-outfit animate-pulse" style={{ letterSpacing: '4px', fontSize: '0.8rem' }}>SCANNING GENOME...</p>
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
                                                {isScanning ? 'Processing...' : 'Start AI Analysis'}
                                            </button>
                                        </div>
                                    </div>
                                )}
                            </div>

                            {scanResult && !scanResult.not_cattle && scanResult.breed_name !== "Unidentified" && (
                                <div className="glass-card animate-scale-in" style={{ marginTop: '2rem', border: '1px solid var(--primary)', position: 'relative', overflow: 'hidden' }}>
                                    <div style={{ position: 'absolute', top: 0, right: 0, padding: '0.5rem 1rem', background: 'var(--primary)', color: 'white', borderRadius: '0 0 0 1rem', fontSize: '0.75rem', fontWeight: 700 }}>
                                        RESULT VERIFIED
                                    </div>
                                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '2rem' }}>
                                        <div style={{ textAlign: 'center' }}>
                                            <p style={{ color: 'var(--text-dim)', fontSize: '0.8rem', textTransform: 'uppercase', marginBottom: '0.5rem' }}>Breed Name</p>
                                            <h3 style={{ color: 'var(--primary)', fontSize: '1.5rem' }}>{scanResult.breed_name}</h3>
                                        </div>
                                        <div style={{ textAlign: 'center' }}>
                                            <p style={{ color: 'var(--text-dim)', fontSize: '0.8rem', textTransform: 'uppercase', marginBottom: '0.5rem' }}>Confidence</p>
                                            <h3 style={{ fontSize: '1.5rem' }}>{Math.round(scanResult.confidence_score)}%</h3>
                                        </div>
                                        <div style={{ textAlign: 'center' }}>
                                            <p style={{ color: 'var(--text-dim)', fontSize: '0.8rem', textTransform: 'uppercase', marginBottom: '0.5rem' }}>Avg Yield</p>
                                            <h3 style={{ fontSize: '1.5rem' }}>{scanResult.yield_estimate}L/day</h3>
                                        </div>
                                    </div>
                                    <div style={{ marginTop: '2rem', display: 'flex', gap: '1.5rem' }}>
                                        <div className="glass" style={{ flex: 1, padding: '1rem', borderRadius: '0.75rem' }}>
                                            <div style={{ color: 'var(--text-dim)', fontSize: '0.75rem', marginBottom: '0.25rem' }}>TYPE</div>
                                            <div style={{ fontWeight: 600 }}>{scanResult.animal_type}</div>
                                        </div>
                                        <div className="glass" style={{ flex: 1, padding: '1rem', borderRadius: '0.75rem' }}>
                                            <div style={{ color: 'var(--text-dim)', fontSize: '0.75rem', marginBottom: '0.25rem' }}>FAT CONTENT</div>
                                            <div style={{ fontWeight: 600 }}>{scanResult.fat_content}</div>
                                        </div>
                                        <div className="glass" style={{ flex: 1, padding: '1rem', borderRadius: '0.75rem' }}>
                                            <div style={{ color: 'var(--text-dim)', fontSize: '0.75rem', marginBottom: '0.25rem' }}>RANGE</div>
                                            <div style={{ fontWeight: 600 }}>{scanResult.milk_yield_range}</div>
                                        </div>
                                    </div>

                                    <div style={{ marginTop: '1rem', textAlign: 'center', opacity: 0.6, fontSize: '0.85rem' }}>
                                        <p>Verification data secured in regional database.</p>
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
                    </div>
                )}

                {activeTab === 'history' && (
                    <div className="animate-fade-in">
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
                            <h2 className="font-outfit" style={{ fontSize: '2rem' }}>Scan History</h2>
                            <button className="btn-outline" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                                <Download size={16} /> Export CSV
                            </button>
                        </div>
                        <div className="glass-card" style={{ padding: 0 }}>
                            <div style={{ overflowX: 'auto' }}>
                                <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                                    <thead>
                                        <tr style={{ background: 'rgba(255,255,255,0.02)', textAlign: 'left' }}>
                                            <th style={{ padding: '1.25rem' }}>Visual Asset</th>
                                            <th style={{ padding: '1.25rem' }}>Ear Tag</th>
                                            <th style={{ padding: '1.25rem' }}>Detection Result</th>
                                            <th style={{ padding: '1.25rem' }}>Confidence</th>
                                            <th style={{ padding: '1.25rem' }}>Yield Info</th>
                                            <th style={{ padding: '1.25rem' }}>Timestamp</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {detections.length > 0 ? detections.map((det, i) => (
                                            <tr key={i} style={{ borderBottom: '1px solid var(--glass-border)' }}>
                                                <td style={{ padding: '1rem' }}>
                                                    <div style={{ width: '60px', height: '60px', borderRadius: '0.75rem', overflow: 'hidden', border: '1px solid var(--glass-border)' }}>
                                                        <img src={`http://localhost:8000/${det.image_path}`} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                                    </div>
                                                </td>
                                                <td style={{ padding: '1rem' }}>
                                                    <span style={{ fontSize: '0.85rem', fontWeight: 600 }}>{det.animal_ear_tag || 'N/A'}</span>
                                                </td>
                                                <td style={{ padding: '1rem' }}>
                                                    <div style={{ fontWeight: 700, color: 'var(--primary)' }}>{det.breed_name}</div>
                                                    <div style={{ fontSize: '0.75rem', color: 'var(--text-dim)' }}>Type: {det.animal_type}</div>
                                                </td>
                                                <td style={{ padding: '1rem' }}>
                                                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                                                        <div style={{ width: '60px', height: '6px', background: 'rgba(255,255,255,0.05)', borderRadius: '3px' }}>
                                                            <div style={{ width: `${det.confidence_score}%`, height: '100%', background: 'var(--primary)', borderRadius: '3px' }}></div>
                                                        </div>
                                                        <span style={{ fontSize: '0.85rem' }}>{Math.round(det.confidence_score)}%</span>
                                                    </div>
                                                </td>
                                                <td style={{ padding: '1rem' }}>
                                                    <div>{det.yield_estimate} L/day</div>
                                                    <div style={{ fontSize: '0.75rem', color: 'var(--text-dim)' }}>Fat: {det.fat_content}</div>
                                                </td>
                                                <td style={{ padding: '1rem', color: 'var(--text-dim)', fontSize: '0.85rem' }}>
                                                    {new Date(det.detected_at).toLocaleString([], { dateStyle: 'medium', timeStyle: 'short' })}
                                                </td>
                                            </tr>
                                        )) : (
                                            <tr>
                                                <td colSpan={5} style={{ padding: '4rem', textAlign: 'center', color: 'var(--text-dim)' }}>
                                                    <div style={{ opacity: 0.5, marginBottom: '1rem' }}>
                                                        <History size={48} style={{ margin: '0 auto' }} />
                                                    </div>
                                                    <p>No scans analyzed yet. Your herd history will appear here.</p>
                                                </td>
                                            </tr>
                                        )}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                )}

                {activeTab === 'timetable' && <Timetable />}
                {activeTab === 'comparison' && <BreedComparison />}

                {activeTab === 'analytics' && (
                    <div className="animate-fade-in">
                        <h2 className="font-outfit" style={{ fontSize: '2rem', marginBottom: '2rem' }}>Advanced Analytics</h2>
                        <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '1.5rem' }}>
                            <div className="glass-card">
                                <h3 style={{ marginBottom: '2rem' }}>Milk Production & Quality Trends</h3>
                                <div style={{ width: '100%', height: '400px' }}>
                                    <ResponsiveContainer width="100%" height="100%">
                                        <AreaChart data={chartData}>
                                            <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" vertical={false} />
                                            <XAxis dataKey="name" stroke="var(--text-dim)" fontSize={12} tickLine={false} axisLine={false} />
                                            <YAxis stroke="var(--text-dim)" fontSize={12} tickLine={false} axisLine={false} />
                                            <Tooltip contentStyle={{ background: 'var(--background)', border: '1px solid var(--glass-border)' }} />
                                            <Area type="monotone" dataKey="yield" stroke="var(--primary)" fill="rgba(16, 185, 129, 0.1)" name="Yield (L)" />
                                            <Area type="monotone" dataKey="fat" stroke="var(--secondary)" fill="rgba(99, 102, 241, 0.1)" name="Fat %" />
                                        </AreaChart>
                                    </ResponsiveContainer>
                                </div>
                            </div>
                            <div className="glass-card">
                                <h3 style={{ marginBottom: '2rem' }}>Insights</h3>
                                <div className="flex flex-col gap-4">
                                    {[
                                        { icon: CheckCircle, color: '#10b981', title: 'Optimal Production', desc: 'Yield is 12% above district average this week.' },
                                        { icon: TrendingUp, color: '#6366f1', title: 'Fat Consistency', desc: 'Milk fat levels have stabilized at 4.2%.' },
                                        { icon: AlertCircle, color: '#f59e0b', title: 'Upcoming Weather', desc: 'Summer heat may impact yield. Increase water supply.' }
                                    ].map((insight, i) => (
                                        <div key={i} className="glass" style={{ padding: '1.5rem', borderRadius: '1rem' }}>
                                            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '0.5rem' }}>
                                                <insight.icon size={20} color={insight.color} />
                                                <span style={{ fontWeight: 700 }}>{insight.title}</span>
                                            </div>
                                            <p style={{ fontSize: '0.85rem', color: 'var(--text-dim)', lineHeight: 1.5 }}>{insight.desc}</p>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </div>
                    </div>
                )}

                {activeTab === 'settings' && (
                    <div className="animate-fade-in" style={{ maxWidth: '800px' }}>
                        <h2 className="font-outfit" style={{ fontSize: '2rem', marginBottom: '2rem' }}>Farmer Profile</h2>
                        <div className="glass-card" style={{ padding: '2.5rem' }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '2rem', marginBottom: '3rem' }}>
                                <div style={{ position: 'relative' }}>
                                    <div style={{ width: '120px', height: '120px', borderRadius: '24px', overflow: 'hidden', border: '4px solid var(--secondary)' }}>
                                        <img src={userProfile?.profile_photo ? `http://localhost:8000/${userProfile.profile_photo}` : `https://api.dicebear.com/7.x/avataaars/svg?seed=${userProfile?.full_name || 'Farmer'}`} alt="Profile Large" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                    </div>
                                    <input
                                        type="file"
                                        id="profile-photo-input"
                                        style={{ display: 'none' }}
                                        onChange={handlePhotoUpload}
                                        accept="image/*"
                                    />
                                    <button
                                        onClick={() => document.getElementById('profile-photo-input')?.click()}
                                        disabled={isUpdating}
                                        style={{ position: 'absolute', bottom: '-10px', right: '-10px', width: '40px', height: '40px', borderRadius: '12px', background: 'var(--primary)', color: 'white', border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 4px 12px rgba(0,0,0,0.3)', cursor: 'pointer' }}
                                    >
                                        <Camera size={18} />
                                    </button>
                                </div>
                                <div>
                                    <h2 style={{ fontSize: '1.75rem', marginBottom: '0.25rem' }}>{userProfile?.full_name}</h2>
                                    <p style={{ color: 'var(--text-dim)' }}>Premium Farmer Member since 2024</p>
                                    <div style={{ display: 'flex', gap: '0.5rem', marginTop: '1rem' }}>
                                        <span style={{ background: 'rgba(16, 185, 129, 0.1)', color: 'var(--primary)', padding: '0.25rem 0.75rem', borderRadius: '1rem', fontSize: '0.75rem', fontWeight: 700 }}>VERIFIED</span>
                                        <span style={{ background: 'rgba(99, 102, 241, 0.1)', color: 'var(--secondary)', padding: '0.25rem 0.75rem', borderRadius: '1rem', fontSize: '0.75rem', fontWeight: 700 }}>PRO BUNDLE</span>
                                    </div>
                                </div>
                            </div>

                            <form onSubmit={handleProfileUpdate} style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem' }}>
                                <div className="input-group">
                                    <label style={{ display: 'block', color: 'var(--text-dim)', fontSize: '0.85rem', marginBottom: '0.75rem' }}>Full Name</label>
                                    <div className="glass" style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', padding: '0.75rem 1rem', borderRadius: '0.75rem' }}>
                                        <User size={18} color="var(--primary)" />
                                        <input
                                            value={profileFormData.full_name}
                                            onChange={(e) => setProfileFormData({ ...profileFormData, full_name: e.target.value })}
                                            style={{ background: 'none', border: 'none', color: 'white', width: '100%', outline: 'none' }}
                                        />
                                    </div>
                                </div>
                                <div className="input-group">
                                    <label style={{ display: 'block', color: 'var(--text-dim)', fontSize: '0.85rem', marginBottom: '0.75rem' }}>Phone Number</label>
                                    <div className="glass" style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', padding: '0.75rem 1rem', borderRadius: '0.75rem' }}>
                                        <Phone size={18} color="var(--primary)" />
                                        <input
                                            value={profileFormData.phone_number}
                                            onChange={(e) => setProfileFormData({ ...profileFormData, phone_number: e.target.value })}
                                            style={{ background: 'none', border: 'none', color: 'white', width: '100%', outline: 'none' }}
                                        />
                                    </div>
                                </div>
                                <div className="input-group">
                                    <label style={{ display: 'block', color: 'var(--text-dim)', fontSize: '0.85rem', marginBottom: '0.75rem' }}>Email Address</label>
                                    <div className="glass" style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', padding: '0.75rem 1rem', borderRadius: '0.75rem' }}>
                                        <Mail size={18} color="var(--primary)" />
                                        <input
                                            value={profileFormData.email}
                                            readOnly
                                            style={{ background: 'none', border: 'none', color: 'rgba(255,255,255,0.5)', width: '100%', outline: 'none', cursor: 'not-allowed' }}
                                        />
                                    </div>
                                </div>
                                <div className="input-group" style={{ display: 'flex', alignItems: 'flex-end' }}>
                                    <button
                                        type="submit"
                                        disabled={isUpdating}
                                        className="btn-premium"
                                        style={{ width: '100%', opacity: isUpdating ? 0.7 : 1 }}
                                    >
                                        {isUpdating ? 'Updating...' : 'Update Profile'}
                                    </button>
                                </div>
                            </form>

                            <div style={{ marginTop: '3rem', paddingTop: '2rem', borderTop: '1px solid var(--glass-border)' }}>
                                <button
                                    onClick={handleDeleteAccount}
                                    className="btn-outline"
                                    style={{ color: '#ef4444', borderColor: 'rgba(239, 68, 68, 0.2)' }}
                                >
                                    Delete Account
                                </button>
                            </div>
                        </div>
                    </div>
                )}
            </main>
        </div>
    );
};

export default FarmerDashboard;

import { useState } from 'react';
import LandingPage from './components/LandingPage';
import AuthPage from './components/AuthPage';
import FarmerDashboard from './components/FarmerDashboard';
import BPADashboard from './components/BPADashboard';

type View = 'landing' | 'auth' | 'farmer_dashboard' | 'bpa_dashboard';

function App() {
  const [view, setView] = useState<View>('landing');

  const handleGetStarted = () => setView('auth');
  const handleBackToLanding = () => setView('landing');

  const handleLoginSuccess = (role: 'farmer' | 'bpa') => {
    setView(role === 'farmer' ? 'farmer_dashboard' : 'bpa_dashboard');
  };

  const handleLogout = () => {
    setView('landing');
  };

  return (
    <div className="app-container">
      {view === 'landing' && <LandingPage onGetStarted={handleGetStarted} />}
      {view === 'auth' && (
        <AuthPage
          onBack={handleBackToLanding}
          onLoginSuccess={handleLoginSuccess}
        />
      )}
      {view === 'farmer_dashboard' && <FarmerDashboard onLogout={handleLogout} />}
      {view === 'bpa_dashboard' && <BPADashboard onLogout={handleLogout} />}
    </div>
  );
}

export default App;

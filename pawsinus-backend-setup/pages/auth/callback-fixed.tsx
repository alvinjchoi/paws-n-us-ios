import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';

export default function AuthCallback() {
  const router = useRouter();
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading');
  const [errorMessage, setErrorMessage] = useState('');
  const [debugInfo, setDebugInfo] = useState<any>({});

  useEffect(() => {
    // Get the full URL including hash fragment
    const hash = window.location.hash;
    const search = window.location.search;
    const fullUrl = window.location.href;
    
    // Debug information
    setDebugInfo({
      hash,
      search,
      fullUrl,
      hasAccessToken: hash.includes('access_token')
    });
    
    // Check if we have auth tokens in the URL
    if (hash && hash.includes('access_token')) {
      // Success - redirect to the iOS app with the auth tokens
      const appUrl = `pawsinus://login-callback${hash}`;
      setStatus('success');
      
      // Try to open the app
      window.location.href = appUrl;
      
      // Fallback: Show manual instructions if app doesn't open
      setTimeout(() => {
        // If we're still here after 2 seconds, show manual option
        const manualEl = document.getElementById('manual-instructions');
        if (manualEl) {
          manualEl.style.display = 'block';
        }
      }, 2000);
    } else if (search) {
      // Handle query parameters (for other auth flows)
      const appUrl = `pawsinus://login-callback${search}${hash}`;
      setStatus('success');
      window.location.href = appUrl;
    } else {
      // No auth data found
      setStatus('error');
      setErrorMessage('No authentication data received');
    }
  }, []);

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: '#f3f4f6',
      padding: '1rem',
      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
    }}>
      <div style={{
        maxWidth: '28rem',
        width: '100%',
        backgroundColor: 'white',
        borderRadius: '0.5rem',
        boxShadow: '0 1px 3px rgba(0, 0, 0, 0.1)',
        padding: '2rem'
      }}>
        <div style={{ textAlign: 'center' }}>
          <h1 style={{
            fontSize: '1.5rem',
            fontWeight: 'bold',
            marginBottom: '1rem',
            color: '#1f2937'
          }}>
            PawsInUs
          </h1>
          
          {status === 'loading' && (
            <div>
              <div style={{
                marginBottom: '2rem',
                padding: '1rem',
                backgroundColor: '#dbeafe',
                borderRadius: '0.375rem'
              }}>
                <p style={{ color: '#1e40af', fontSize: '0.875rem' }}>
                  처리 중...
                </p>
              </div>
            </div>
          )}

          {status === 'success' && (
            <div>
              <div style={{
                marginBottom: '2rem',
                padding: '1rem',
                backgroundColor: '#d1fae5',
                borderRadius: '0.375rem'
              }}>
                <p style={{ color: '#065f46', fontSize: '0.875rem' }}>
                  ✓ 인증 성공! 포인어스 앱으로 이동합니다...
                </p>
              </div>

              <div id="manual-instructions" style={{
                marginTop: '2rem',
                padding: '1rem',
                backgroundColor: '#f3f4f6',
                borderRadius: '0.375rem',
                display: 'none'
              }}>
                <p style={{
                  color: '#4b5563',
                  fontSize: '0.875rem',
                  marginBottom: '1rem'
                }}>
                  앱이 자동으로 열리지 않나요?
                </p>
                
                <button
                  onClick={() => {
                    const hash = window.location.hash;
                    const search = window.location.search;
                    const appUrl = `pawsinus://login-callback${search}${hash}`;
                    window.location.href = appUrl;
                  }}
                  style={{
                    backgroundColor: '#f97316',
                    color: 'white',
                    padding: '0.5rem 1rem',
                    borderRadius: '0.375rem',
                    border: 'none',
                    cursor: 'pointer',
                    fontSize: '0.875rem',
                    fontWeight: '500'
                  }}
                >
                  앱에서 열기
                </button>
              </div>
            </div>
          )}

          {status === 'error' && (
            <div>
              <div style={{
                marginBottom: '2rem',
                padding: '1rem',
                backgroundColor: '#fee2e2',
                borderRadius: '0.375rem'
              }}>
                <div style={{
                  width: '48px',
                  height: '48px',
                  backgroundColor: '#fecaca',
                  borderRadius: '50%',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  margin: '0 auto 1rem'
                }}>
                  <span style={{ color: '#dc2626', fontSize: '24px' }}>✕</span>
                </div>
                <p style={{ color: '#dc2626', fontSize: '1rem', fontWeight: '500' }}>
                  {errorMessage}
                </p>
              </div>

              <div style={{
                marginTop: '1rem',
                padding: '1rem',
                backgroundColor: '#f9fafb',
                borderRadius: '0.375rem',
                textAlign: 'left'
              }}>
                <p style={{
                  fontSize: '0.75rem',
                  color: '#6b7280',
                  marginBottom: '0.5rem',
                  fontWeight: '500'
                }}>
                  Debug Information:
                </p>
                <pre style={{
                  fontSize: '0.75rem',
                  color: '#1f2937',
                  overflow: 'auto',
                  backgroundColor: '#f3f4f6',
                  padding: '0.5rem',
                  borderRadius: '0.25rem'
                }}>
                  {JSON.stringify(debugInfo, null, 2)}
                </pre>
              </div>

              <p style={{
                marginTop: '2rem',
                fontSize: '0.875rem',
                color: '#6b7280'
              }}>
                Having trouble? Make sure the PawsInUs app is installed on your device.
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
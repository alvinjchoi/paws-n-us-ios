import { useEffect } from 'react';
import { useRouter } from 'next/router';

export default function AuthCallback() {
  const router = useRouter();

  useEffect(() => {
    // Get the full URL including hash fragment
    const hash = window.location.hash;
    const search = window.location.search;
    
    // Check if we have auth tokens in the URL
    if (hash && hash.includes('access_token')) {
      // Redirect to the iOS app with the auth tokens
      const appUrl = `pawsinus://login-callback${hash}`;
      window.location.href = appUrl;
      
      // Fallback: Show instructions if app doesn't open
      setTimeout(() => {
        // If we're still here, the app didn't open
        document.getElementById('manual-instructions')?.classList.remove('hidden');
      }, 2000);
    } else if (search) {
      // Handle query parameters (for other auth flows)
      const appUrl = `pawsinus://login-callback${search}${hash}`;
      window.location.href = appUrl;
    }
  }, []);

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: '#f3f4f6',
      padding: '1rem'
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
            로그인 중...
          </h1>
          
          <div style={{
            marginBottom: '2rem',
            padding: '1rem',
            backgroundColor: '#fef3c7',
            borderRadius: '0.375rem'
          }}>
            <p style={{ color: '#92400e', fontSize: '0.875rem' }}>
              포인어스 앱으로 자동으로 이동합니다...
            </p>
          </div>

          <div id="manual-instructions" className="hidden" style={{
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
            
            <div style={{
              marginTop: '1rem',
              padding: '0.75rem',
              backgroundColor: 'white',
              borderRadius: '0.375rem',
              border: '1px solid #e5e7eb'
            }}>
              <p style={{
                fontSize: '0.75rem',
                color: '#6b7280',
                marginBottom: '0.5rem'
              }}>
                수동으로 복사하려면:
              </p>
              <code style={{
                fontSize: '0.75rem',
                color: '#1f2937',
                wordBreak: 'break-all',
                display: 'block',
                padding: '0.5rem',
                backgroundColor: '#f9fafb',
                borderRadius: '0.25rem'
              }}>
                {typeof window !== 'undefined' ? window.location.href : ''}
              </code>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
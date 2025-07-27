import { useEffect } from 'react';

export default function AuthCallback() {
  useEffect(() => {
    // Get parameters from URL
    const urlParams = new URLSearchParams(window.location.search);
    const code = urlParams.get('code');
    const error = urlParams.get('error');
    const errorDescription = urlParams.get('error_description');
    
    if (error) {
      // Display error
      console.error('Authentication error:', error, errorDescription);
      return;
    }
    
    if (code) {
      // Redirect to iOS app with the authorization code
      const appRedirectUrl = `pawsinus://login-callback?code=${code}`;
      
      // Attempt to redirect to the app
      window.location.href = appRedirectUrl;
      
      // Show fallback UI after a delay
      setTimeout(() => {
        const fallback = document.getElementById('fallback-ui');
        if (fallback) {
          fallback.style.display = 'block';
        }
      }, 1500);
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
        padding: '2rem',
        textAlign: 'center'
      }}>
        <h1 style={{
          fontSize: '1.5rem',
          fontWeight: 'bold',
          marginBottom: '1rem',
          color: '#1f2937'
        }}>
          포인어스
        </h1>
        
        <div style={{
          marginBottom: '2rem',
          padding: '1rem',
          backgroundColor: '#d1fae5',
          borderRadius: '0.375rem'
        }}>
          <p style={{ color: '#065f46', fontSize: '0.875rem' }}>
            인증 성공! 앱으로 이동 중...
          </p>
        </div>

        <div id="fallback-ui" style={{ display: 'none' }}>
          <p style={{
            marginBottom: '1rem',
            color: '#6b7280',
            fontSize: '0.875rem'
          }}>
            앱이 자동으로 열리지 않나요?
          </p>
          
          <button
            onClick={() => {
              const code = new URLSearchParams(window.location.search).get('code');
              if (code) {
                window.location.href = `pawsinus://login-callback?code=${code}`;
              }
            }}
            style={{
              backgroundColor: '#f97316',
              color: 'white',
              padding: '0.75rem 1.5rem',
              borderRadius: '0.375rem',
              border: 'none',
              cursor: 'pointer',
              fontSize: '1rem',
              fontWeight: '500',
              marginBottom: '1rem'
            }}
          >
            포인어스 앱 열기
          </button>
          
          <div style={{
            marginTop: '1rem',
            padding: '1rem',
            backgroundColor: '#f9fafb',
            borderRadius: '0.375rem',
            fontSize: '0.75rem',
            color: '#6b7280'
          }}>
            <p style={{ marginBottom: '0.5rem' }}>
              여전히 작동하지 않나요?
            </p>
            <p>
              1. 포인어스 앱이 설치되어 있는지 확인하세요<br/>
              2. Safari에서 이 페이지를 열어보세요<br/>
              3. 앱을 다시 설치해보세요
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
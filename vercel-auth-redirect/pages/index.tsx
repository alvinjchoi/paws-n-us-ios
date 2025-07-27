export default function Home() {
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
        maxWidth: '42rem',
        textAlign: 'center'
      }}>
        <h1 style={{
          fontSize: '3rem',
          fontWeight: 'bold',
          color: '#f97316',
          marginBottom: '1rem'
        }}>
          포인어스
        </h1>
        <p style={{
          fontSize: '1.25rem',
          color: '#4b5563'
        }}>
          운명의 반려견을 만나보세요
        </p>
      </div>
    </div>
  );
}
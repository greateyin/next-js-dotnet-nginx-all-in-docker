import { useEffect, useState } from 'react';

export default function Home() {
  const [data, setData] = useState(null);

  useEffect(() => {
    fetch('/api/data')
      .then((res) => res.json())
      .then((data) => setData(data));
  }, []);

  return (
    <div>
      <h1>Next.js + .NET Core API Example</h1>
      <p>API Response: {data ? JSON.stringify(data) : 'Loading...'}</p>
    </div>
  );
}
export function formatCurrency(amount: number): string {
  return new Intl.NumberFormat('th-TH', {
    style: 'currency',
    currency: 'THB',
  }).format(amount);
}

export function formatDate(dateString: string): string {
  return new Date(dateString).toLocaleDateString('th-TH', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  });
}

export function calculateGPA(grades: { letter: string }[]): number {
  const gradeMap: Record<string, number> = {
    A: 4.0,
    'B+': 3.5,
    B: 3.0,
    'C+': 2.5,
    C: 2.0,
    'D+': 1.5,
    D: 1.0,
    F: 0.0,
  };

  if (grades.length === 0) return 0;

  const total = grades.reduce((sum, g) => sum + (gradeMap[g.letter] || 0), 0);
  return parseFloat((total / grades.length).toFixed(2));
}

const API_URL = process.env.NEXT_PUBLIC_API_URL + '/books';

interface Book {
    id?: number;
    title: string;
    author: string;
    description: string;
  }

export const fetchBooks = async (): Promise<Book[]> => {
  const response = await fetch(API_URL);
  return response.json();
};

export const fetchBookById = async (id: number): Promise<Book> => {
  const response = await fetch(`${API_URL}/${id}`);
  return response.json();
};

export const createBook = async (book: Book): Promise<Book> => {
  const response = await fetch(API_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(book),
  });
  return response.json();
};

export const updateBook = async (id: number, book: Book): Promise<Book> => {
  const response = await fetch(`${API_URL}/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(book),
  });
  return response.json();
};

export const deleteBook = async (id: number): Promise<void> => {
  await fetch(`${API_URL}/${id}`, { method: 'DELETE' });
};
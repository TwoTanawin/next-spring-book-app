"use client"

import { useState, useEffect } from 'react';
import {
  Container,
  Typography,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  IconButton,
} from '@mui/material';
import { Edit as EditIcon, Delete as DeleteIcon } from '@mui/icons-material';
import BookForm from './components/BookForm';
import { fetchBooks, createBook, updateBook, deleteBook } from './api/bookApi';

interface Book {
  id?: number;
  title: string;
  author: string;
  description: string;
}

export default function Home() {
  const [books, setBooks] = useState<Book[]>([]);
  const [open, setOpen] = useState(false);
  const [selectedBook, setSelectedBook] = useState<Book | null>(null);

  useEffect(() => {
    loadBooks();
  }, []);

  const loadBooks = async () => {
    const data = await fetchBooks();
    setBooks(data);
  };

  const handleCreate = async (book: Book) => {
    await createBook(book);
    loadBooks();
  };

  const handleUpdate = async (book: Book) => {
    if (selectedBook?.id) {
      await updateBook(selectedBook.id, book);
      loadBooks();
    }
  };

  const handleDelete = async (id: number) => {
    await deleteBook(id);
    loadBooks();
  };

  const handleEdit = (book: Book) => {
    setSelectedBook(book);
    setOpen(true);
  };

  return (
    <Container maxWidth="lg">
      <Typography variant="h4" component="h1" gutterBottom>
        Book Management
      </Typography>
      <Button
        variant="contained"
        color="primary"
        onClick={() => {
          setSelectedBook(null);
          setOpen(true);
        }}
      >
        Add New Book
      </Button>
      <TableContainer component={Paper} sx={{ mt: 2 }}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Title</TableCell>
              <TableCell>Author</TableCell>
              <TableCell>Description</TableCell>
              <TableCell>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {books.map((book) => (
              <TableRow key={book.id}>
                <TableCell>{book.title}</TableCell>
                <TableCell>{book.author}</TableCell>
                <TableCell>{book.description}</TableCell>
                <TableCell>
                  <IconButton onClick={() => handleEdit(book)}>
                    <EditIcon />
                  </IconButton>
                  <IconButton onClick={() => handleDelete(book.id!)}>
                    <DeleteIcon />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
      <BookForm
        open={open}
        onClose={() => setOpen(false)}
        onSubmit={selectedBook ? handleUpdate : handleCreate}
        initialData={selectedBook || undefined}
      />
    </Container>
  );
}
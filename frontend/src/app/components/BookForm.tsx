import { useState } from 'react';
import { Dialog, DialogTitle, DialogContent, DialogActions, Button, TextField } from '@mui/material';

interface Book {
    id?: number;
    title: string;
    author: string;
    description: string;
  }

interface BookFormProps {
  open: boolean;
  onClose: () => void;
  onSubmit: (book: Book) => void;
  initialData?: Book;
}

export default function BookForm({ open, onClose, onSubmit, initialData }: BookFormProps) {
  const [book, setBook] = useState<Book>(initialData || {
    title: '',
    author: '',
    description: ''
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(book);
    onClose();
  };

  return (
    <Dialog open={open} onClose={onClose}>
      <DialogTitle>{initialData ? 'Edit Book' : 'Add New Book'}</DialogTitle>
      <form onSubmit={handleSubmit}>
        <DialogContent>
          <TextField
            autoFocus
            margin="dense"
            label="Title"
            fullWidth
            value={book.title}
            onChange={(e) => setBook({ ...book, title: e.target.value })}
          />
          <TextField
            margin="dense"
            label="Author"
            fullWidth
            value={book.author}
            onChange={(e) => setBook({ ...book, author: e.target.value })}
          />
          <TextField
            margin="dense"
            label="Description"
            fullWidth
            multiline
            rows={4}
            value={book.description}
            onChange={(e) => setBook({ ...book, description: e.target.value })}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={onClose}>Cancel</Button>
          <Button type="submit" variant="contained" color="primary">
            {initialData ? 'Update' : 'Create'}
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  );
}
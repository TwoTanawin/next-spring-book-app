package com.tanawin.BookAPI.services;

import com.tanawin.BookAPI.models.Book;
import com.tanawin.BookAPI.repository.BookRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class BookService {
    @Autowired
    private BookRepository bookRepository;

    public List<Book> getAllBooks(){
        return bookRepository.findAll();
    }

    public Book getBookById(int id){
        return bookRepository.findById(id).orElse(null);
    }

    public Book createBook(Book book){
        return bookRepository.save(book);
    }

    public Book updateBook(int id, Book bookDetails){
        Optional<Book> optionalBook = bookRepository.findById(id);
        if(optionalBook.isPresent()){
            Book book = optionalBook.get();
            book.setTitle(bookDetails.getTitle());
            book.setAuthor(bookDetails.getAuthor());
            book.setDescription(bookDetails.getDescription());
            return bookRepository.save(book);
        }
        return null;
    }

    public boolean deleteBook(int id) {
        if (bookRepository.existsById(id)) {
            bookRepository.deleteById(id);
            return true;
        }
        return false;
    }
}

require('dotenv').config();
const express = require('express');
const mysql = require('mysql2');
const session = require('express-session');
const flash = require('connect-flash');
const app = express();

const connection = mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'c237_adventuredb'
});


connection.connect((err) => {
    if (err) {
        console.error('Error connecting to MySQL:', err);
        return;
    }
    console.log('Connected to MySQL database');
});

// Set up view engine
app.set('view engine', 'ejs');
// enable static files
app.use(express.static('public'));
// enable form processing
app.use(express.urlencoded({ extended: false }));

app.use(session({
    secret: 'secret',
    resave: false,
    saveUninitialized: true,
    cookie: { maxAge: 1000 * 60 * 60 * 24 * 7 } // 1 week
}));

app.use(flash());

// Makes the current path available in every view without changing every
// res.render() call - used by the navbar partial to highlight the active link.
app.use((req, res, next) => {
    res.locals.currentPath = req.path;
    res.locals.successMsg = req.flash('success');
    res.locals.errorMsg = req.flash('error');
    next();
});

// ============================================================
// Shared middleware
// ============================================================

// Middleware to check if user is logged in
const checkAuthenticated = (req, res, next) => {
    if (req.session.user) {
        return next();
    } else {
        req.flash('error', 'Please log in to view this resource');
        res.redirect('/login');
    }
};

// Middleware to check if user is admin
const checkAdmin = (req, res, next) => {
    if (req.session.user && req.session.user.role === 'admin') {
        return next();
    } else {
        req.flash('error', 'Access denied');
        res.redirect('/explore');
    }
};

const validateRegistration = (req, res, next) => {
    const { username, email, password } = req.body;

    if (!username || !email || !password) {
        req.flash('error', 'All fields are required.');
        return res.redirect('/register');
    }

    if (password.length < 6) {
        req.flash('error', 'Password should be at least 6 characters long');
        return res.redirect('/register');
    }
    next();
};

app.get('/', (req, res) => {
    res.render('index', { user: req.session.user });
});

// ============================================================
// STUDENT A: Registration, Login and Access Control
// ============================================================

app.get('/register', (req, res) => {
    res.render('register', { messages: req.flash('error'), user: req.session.user });
});

app.post('/register', validateRegistration, (req, res) => {
    const { username, email, password } = req.body;
    // role is always 'explorer' on self-registration; only an existing
    // admin can promote someone via a direct DB update for this project's scope
    const sql = 'INSERT INTO users (username, email, password, role) VALUES (?, ?, SHA1(?), ?)';
    connection.query(sql, [username, email, password, 'explorer'], (err, result) => {
        if (err) {
            console.error('Error registering user:', err);
            req.flash('error', 'That username or email is already taken.');
            return res.redirect('/register');
        }
        req.flash('success', 'Registration successful! Please log in.');
        res.redirect('/login');
    });
});

app.get('/login', (req, res) => {
    res.render('login', { messages: req.flash('success'), errors: req.flash('error'), user: req.session.user });
});

app.post('/login', (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        req.flash('error', 'All fields are required.');
        return res.redirect('/login');
    }

    const sql = 'SELECT * FROM users WHERE email = ? AND password = SHA1(?)';
    connection.query(sql, [email, password], (err, results) => {
        if (err) throw err;

        if (results.length > 0) {
            req.session.user = results[0];
            req.flash('success', 'Login successful!');
            res.redirect('/explore');
        } else {
            req.flash('error', 'Invalid email or password.');
            res.redirect('/login');
        }
    });
});

app.get('/logout', (req, res) => {
    req.session.destroy();
    res.redirect('/');
});

// ============================================================
// STUDENT B: Adding New Information to the System
// (new experiences by admin, and marking an experience complete by explorers)
// ============================================================

app.get('/experiences/new', checkAuthenticated, checkAdmin, (req, res) => {
    res.render('addExperience', { user: req.session.user });
});

app.post('/experiences', checkAuthenticated, checkAdmin, (req, res) => {
    const { title, description, category, location, difficulty } = req.body;
    const sql = 'INSERT INTO experiences (title, description, category, location, difficulty, created_by) VALUES (?, ?, ?, ?, ?, ?)';
    connection.query(sql, [title, description, category, location, difficulty, req.session.user.id], (err) => {
        if (err) {
            console.error('Error adding experience:', err);
            req.flash('error', 'Could not add experience.');
            return res.redirect('/experiences/new');
        }
        req.flash('success', 'Experience added!');
        res.redirect('/explore');
    });
});

app.post('/experiences/:id/complete', checkAuthenticated, (req, res) => {
    const experienceId = req.params.id;
    const { rating, notes, completed_at } = req.body;
    const sql = 'INSERT INTO completions (user_id, experience_id, rating, notes, completed_at) VALUES (?, ?, ?, ?, ?)';
    connection.query(sql, [req.session.user.id, experienceId, rating, notes, completed_at], (err) => {
        if (err) {
            console.error('Error marking complete:', err);
            req.flash('error', 'You may have already marked this experience as complete.');
            return res.redirect('/experiences/' + experienceId);
        }
        req.flash('success', 'Nice! Marked as completed.');
        res.redirect('/experiences/' + experienceId);
    });
});

// ============================================================
// STUDENT C: Viewing and Displaying Information
// ============================================================

app.get('/explore', checkAuthenticated, (req, res) => {
    // Base query - Student E extends this with search/filter/sort below
    connection.query('SELECT * FROM experiences ORDER BY created_at DESC', (error, results) => {
        if (error) throw error;
        res.render('explore', { experiences: results, user: req.session.user, query: req.query });
    });
});

app.get('/experiences/:id', checkAuthenticated, (req, res) => {
    const experienceId = req.params.id;

    connection.query('SELECT * FROM experiences WHERE id = ?', [experienceId], (error, expResults) => {
        if (error) throw error;
        if (expResults.length === 0) {
            return res.status(404).send('Experience not found');
        }

        connection.query('SELECT * FROM completions WHERE experience_id = ? AND user_id = ?',
            [experienceId, req.session.user.id], (err2, compResults) => {
                if (err2) throw err2;
                res.render('experienceDetail', {
                    experience: expResults[0],
                    completion: compResults.length > 0 ? compResults[0] : null,
                    user: req.session.user
                });
            });
    });
});

app.get('/my-progress', checkAuthenticated, (req, res) => {
    const sql = `
        SELECT e.*, c.id AS completion_id, c.rating, c.notes, c.completed_at
        FROM experiences e
        JOIN completions c ON c.experience_id = e.id
        WHERE c.user_id = ?
        ORDER BY c.completed_at DESC
    `;
    connection.query(sql, [req.session.user.id], (error, completed) => {
        if (error) throw error;

        // Badge logic: 5+ completions in a category earns a badge
        const badgeSql = `
            SELECT e.category, COUNT(*) AS total
            FROM experiences e
            JOIN completions c ON c.experience_id = e.id
            WHERE c.user_id = ?
            GROUP BY e.category
            HAVING COUNT(*) >= 5
        `;
        connection.query(badgeSql, [req.session.user.id], (err2, badges) => {
            if (err2) throw err2;
            res.render('myProgress', { completed, badges, user: req.session.user });
        });
    });
});

// ============================================================
// BONUS: Leaderboard (not tied to a specific student's assigned feature -
// built as extra credit on top of the required 5-way split)
// ============================================================

app.get('/leaderboard', checkAuthenticated, (req, res) => {
    const sql = `
        SELECT u.username, COUNT(c.id) AS total_reviews, ROUND(AVG(c.rating), 1) AS avg_rating_given
        FROM users u
        JOIN completions c ON c.user_id = u.id
        WHERE u.role = 'explorer'
        GROUP BY u.id
        ORDER BY total_reviews DESC
        LIMIT 10
    `;
    connection.query(sql, (error, leaders) => {
        if (error) throw error;
        res.render('leaderboard', { leaders, user: req.session.user });
    });
});

// ============================================================
// STUDENT D: Editing Existing Information
// ============================================================

app.get('/experiences/:id/edit', checkAuthenticated, checkAdmin, (req, res) => {
    connection.query('SELECT * FROM experiences WHERE id = ?', [req.params.id], (error, results) => {
        if (error) throw error;
        if (results.length === 0) return res.status(404).send('Experience not found');
        const experience = results[0];
        res.render("editExperience", {
            experience,
            user: req.session.user,
            messages: req.flash("success"),
            errors: req.flash("error")
        });
    });
});

app.post('/experiences/:id/edit', checkAuthenticated, checkAdmin, (req, res) => {
    const { title, description, category, location, difficulty } = req.body;
    if (
!title ||
!category ||
!location ||
!difficulty
){

req.flash(
"error",
"Please fill in all required fields."
);

return res.redirect(
"/experiences/" +
req.params.id +
"/edit"
);

}
    const sql = 'UPDATE experiences SET title = ?, description = ?, category = ?, location = ?, difficulty = ? WHERE id = ?';
    connection.query(sql, [title, description, category, location, difficulty, req.params.id], (err) => {
        if (err) {
            console.error('Error updating experience:', err);
            req.flash('error', 'Could not update experience.');
            return res.redirect('/experiences/' + req.params.id + '/edit');
        }
        req.flash('success', 'Experience updated.');
        res.redirect('/experiences/' + req.params.id);
    });
});

app.get('/completions/:id/edit', checkAuthenticated, (req, res) => {
    connection.query('SELECT * FROM completions WHERE id = ? AND user_id = ?',
        [req.params.id, req.session.user.id], (error, results) => {
            if (error) throw error;
            if (results.length === 0) return res.status(404).send('Completion not found');
            res.render('editCompletion', {
    completion: results[0],
    user: req.session.user,
    messages: req.flash('success'),
    errors: req.flash('error')
});
        });
});

app.post('/completions/:id/edit', checkAuthenticated, (req, res) => {
    const { rating, notes, completed_at } = req.body;
    if(rating){

if(rating<1 || rating>5){

req.flash(
"error",
"Rating must be between 1 and 5."
);

return res.redirect(
"/completions/" +
req.params.id +
"/edit"
);

}

}
    const sql = 'UPDATE completions SET rating = ?, notes = ?, completed_at = ? WHERE id = ? AND user_id = ?';
    connection.query(sql, [rating, notes, completed_at, req.params.id, req.session.user.id], (err) => {
        if (err) {
            console.error('Error updating completion:', err);
            req.flash('error', 'Could not update your entry.');
            return res.redirect('/my-progress');
        }
        req.flash('success', 'Entry updated.');
        res.redirect('/my-progress');
    });
});

// ============================================================
// STUDENT E: Removing Information + Searching/Filtering/Organising
// ============================================================

app.post('/experiences/:id/delete', checkAuthenticated, checkAdmin, (req, res) => {
    const experienceId = req.params.id;

    // Remove linked completions first (FK constraint has no ON DELETE CASCADE)
    connection.query('DELETE FROM completions WHERE experience_id = ?', [experienceId], (err) => {
        if (err) {
            console.error('Error deleting completions for experience:', err);
            req.flash('error', 'Could not delete experience.');
            return res.redirect('/explore');
        }

        connection.query('DELETE FROM experiences WHERE id = ?', [experienceId], (err2) => {
            if (err2) {
                console.error('Error deleting experience:', err2);
                req.flash('error', 'Could not delete experience.');
                return res.redirect('/explore');
            }
            req.flash('success', 'Experience deleted.');
            res.redirect('/explore');
        });
    });
});

app.post('/completions/:id/delete', checkAuthenticated, (req, res) => {
    connection.query('DELETE FROM completions WHERE id = ? AND user_id = ?',
        [req.params.id, req.session.user.id], (err, result) => {
            if (err) {
                console.error('Error deleting completion:', err);
                req.flash('error', 'Could not remove your entry.');
                return res.redirect('/my-progress');
            }
            if (result.affectedRows === 0) {
                req.flash('error', 'Entry not found or you do not have permission to delete it.');
                return res.redirect('/my-progress');
            }
            req.flash('success', 'Removed from your completed list.');
            res.redirect('/my-progress');
        });
});

// Dedicated search route: builds a dynamic query from category/difficulty/text/sort
// filters and re-renders the same explore view. Kept separate from student C's
// base /explore route so this logic is easy to point to and explain on its own.
app.get('/search', checkAuthenticated, (req, res) => {
    const { category, difficulty, sort, q } = req.query;

    let sql = 'SELECT * FROM experiences WHERE 1=1';
    const params = [];

    if (category) {
        sql += ' AND category = ?';
        params.push(category);
    }

    if (difficulty) {
        sql += ' AND difficulty = ?';
        params.push(difficulty);
    }

    if (q && q.trim()) {
        sql += ' AND (title LIKE ? OR description LIKE ? OR location LIKE ?)';
        const term = `%${q.trim()}%`;
        params.push(term, term, term);
    }

    if (sort === 'title') {
        sql += ' ORDER BY title ASC';
    } else if (sort === 'difficulty') {
        sql += ' ORDER BY FIELD(difficulty, "easy", "moderate", "challenging"), title ASC';
    } else {
        sql += ' ORDER BY created_at DESC';
    }

    connection.query(sql, params, (error, results) => {
        if (error) {
            console.error('Search error:', error);
            req.flash('error', 'Could not run search.');
            return res.redirect('/explore');
        }
        res.render('explore', {
            experiences: results,
            user: req.session.user,
            query: req.query,
            isSearch: true
        });
    });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

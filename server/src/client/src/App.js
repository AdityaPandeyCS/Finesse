import React, { Component } from 'react';
import {BrowserRouter, Route, Switch} from 'react-router-dom';

import Home from './components/Home';
import Navigation from './components/Navigation';
import Users from './components/Users';

class App extends Component {
    constructor(props){
        super(props);
    }

    render() {
        return (
            <BrowserRouter>
                <div>
                    <Navigation />
                    <Switch>
                        <Route path="/admin/" component={Home} exact/>
                        <Route path='/admin/users' component={Users}/>
                    </Switch>
                </div>
            </BrowserRouter>
        );
    }
}

export default App;

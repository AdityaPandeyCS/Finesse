import React from 'react';
import renderer from 'react-test-renderer';
import Home from '../components/Home';

describe("Home page", () => {
    it('It should load home admin page', () => {
        const component = renderer.create(
            <Home/>
        );
        let tree = component.toJSON();
        console.log(tree);
        expect(tree).toMatchSnapshot();
    });
});

